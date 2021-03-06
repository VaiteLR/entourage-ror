org = Organization.create name:"org", description:"org description", phone:"+33102030405", address:"50 avenue des Champs Elysées 75008 Paris"

dredd_user = User.create email:"dredd@test.com", first_name:"Judge", last_name:"Dredd", phone:"+33605040302", organizations:org, manager: true
dredd_user.update_attribute :token, "FAKETOKEN"
dredd_user.update_attribute :sms_code, "123456"

se_nourrir = Category.find_or_create_by(name: "Se nourrir")
se_loger = Category.find_or_create_by(name: "Se loger")
se_soigner = Category.find_or_create_by(name: "Se soigner")
se_rafraichir = Category.find_or_create_by(name: "Se rafraîchir")
s_orienter = Category.find_or_create_by(name: "S'orienter")
s_occuper_de_soi = Category.find_or_create_by(name: "S'occuper de soi")
se_reinserer = Category.find_or_create_by(name: "Se réinsérer")
autres = Category.find_or_create_by(name: "Test")

Poi.create(name:"CASVP (Centre d'action sociale de la Ville de Paris) - Sous-direction de la solidarité et de la lutte contre l'exclusion", description:"Tél. : 01 44 67 18 34 ou 01 44 67 18 28. Fax : 01 44 67 18 71", latitude:48.845401, longitude:2.3696595, adress: "5, boulevard Diderot, 75012", phone:"01 44 67 18 34", website:"", email:"", audience:"", category_id:se_nourrir.id)
Poi.create(name:"Comité médical pour les exilés (COMEDE)", description:"• Centre de santé Hôpital Bicêtre", latitude:48.8725447, longitude:2.3405129, adress: "78, rue du Général-Leclerc, 94270 Le Kremlin-Bicêtre", phone:"", website:"", email:"contact@comede.org", audience:"", category_id:se_soigner.id)
Poi.create(name:"SSDP", description:"Mairie du 1er arr. M° Louvre. Services sociaux départementaux polyvalents (SSDP) : Ouverture du lundi au vendredi 9h-17h. ", latitude:48.8600425, longitude:2.3412674, adress: "4, place du Louvre, 75001", phone:"01 44 50 76 40", website:"", email:"", audience:"", category_id:s_orienter.id)
