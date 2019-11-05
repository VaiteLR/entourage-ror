module OrganizationAdmin
  class InvitationsController < BaseController
    before_action :authenticate_user!, except: :join
    before_action :ensure_org_admin!, except: [:join, :accept]
    before_action :ensure_org_member!, except: [:join, :accept]

    def index
      partner_id = current_user.partner_id
      invitations = PartnerInvitation.where(partner_id: partner_id)

      @status = params[:status] == 'accepted' ? :accepted : :pending

      accepted_invitations = invitations
        .where.not(accepted_at: nil)
        .joins(:invitee).where(users: {partner_id: partner_id})
        .order(accepted_at: :desc)

      pending_invitations = invitations
          .where(invitee_id: nil, accepted_at: nil)
          .where("deleted_at is null or deleted_at > now()")
          .order(invited_at: :desc)

      @invitations = @status == :accepted ? accepted_invitations : pending_invitations
      @counts = {
        accepted: accepted_invitations.count,
        pending:  pending_invitations.count
      }
    end

    def new
      @invitation = PartnerInvitation.new
    end

    def create
      @invitation = OrganizationAdmin::InvitationService.create_invitation(
        invitee_email: invitation_params[:invitee_email],
        partner_id: current_user.partner_id,
        inviter_id: current_user.id,
        invitee_attributes: invitation_params.except(:invitee_email)
      )

      return render :new if @invitation.errors.any?

      OrganizationAdmin::InvitationService.deliver(@invitation)

      render text: "OK"
    end

    # DELETE organization_admin_invitation_path
    def destroy
      invitation = PartnerInvitation.where(partner_id: current_user.partner_id).find(params[:id])
      raise "Invitation is not pending" unless invitation.pending?
      invitation.update_column(:deleted_at, Time.zone.now)
      redirect_to organization_admin_invitations_path
    end

    # resend_organization_admin_invitation_path
    def resend
      invitation = PartnerInvitation.where(partner_id: current_user.partner_id).find(params[:id])
      raise "Invitation is not pending" unless invitation.pending?
      OrganizationAdmin::InvitationService.deliver(invitation)
      redirect_to organization_admin_invitations_path
    end

    def join
      @invitation = PartnerInvitation.find_by(token: params[:token])
      @invitation = nil unless @invitation.pending?
      if @invitation && current_user && current_user.partner_id == @invitation.partner_id
        return redirect_to organization_admin_path
      end
    end

    def accept
      invitation = PartnerInvitation.find_by(token: params[:token])

      raise "Invitation is not pending" unless invitation.pending?

      if current_user.partner_id == invitation.partner_id
        return redirect_to organization_admin_path
      end

      current_user.assign_attributes(
        partner_id: invitation.partner_id,
        partner_admin: invitation.partner.users.empty?,
        partner_role_title: invitation.invitee_role_title,

        first_name: params[:first_name],
        last_name:  params[:last_name],
        email:      params[:email],
      )
      unless current_user.has_password?
        current_user.password = params[:password]
      end

      invitation.assign_attributes(
        invitee_id: current_user.id
      )

      begin
        ActiveRecord::Base.transaction do
          current_user.save!
          invitation.save!
        end
      rescue ActiveRecord::RecordInvalid => e
        Raven.capture_exception(e)
        return redirect_to join_organization_admin_invitation_path(token: invitation.token, error: :unknown)
      end

      redirect_to organization_admin_path
    end

    protected

    def invitation_params
      params.require(:partner_invitation).permit(
        :invitee_email, :invitee_name, :invitee_role_title
      )
    end
  end
end
