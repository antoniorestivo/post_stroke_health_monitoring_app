# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

users = User.new({email: "person1@icecream.com", password_digest: "password1"})
users.save

journals = Journal.new({user_id: 1, description: "Patient is overly angry today which is driving blood pressure", image_url: "img url", video_url: "video url", health_routines: "Weight lifting.Alot of spicy foods.", bp_avg: "150/90", bp_annotations: "Perhaps the bp comes from too much weigh lifting and spicy food.", image_of_tongue: "tongue image url"})
journals.save

journals = Journal.new({user_id: 1, description: "Can't walk or talk fluently due to ataxia. Much calmer than yesterday and not overly angry", image_url: "img url", video_url: "video url", health_routines: "Light on the elliptical track. No spicy foods.", bp_avg: "130/ 85", bp_annotations: "Much calmer but with some strong activity- but not overly strong.", image_of_tongue: "tongue image url"})
journals.save

conditions = Condition.new({user_id: 1, name: "dropped elbow", support: 0, treatment_retrospect: "Do have a treatment plan that needs to be done.", treatment_plan: "10 minutes gently of plum needle technique on good arm and 20 minutes more strongly on bad arm.", image_url: "img url", video_url: "video url"})
conditions.save

conditions = Condition.new({user_id: 1, name: "ataxia", support: 0, treatment_retrospect: "Past treatment plan has not been overly effective. Patient finds that some treatments are overbearing. Though it could need to take time for it to work.  May need to try facial acupressure treatment to help connect ren and du meridian.", treatment_plan: "10 minutes moxa treatment on K1 acupressure point on foot. 20 minutes strong acupressure on toes. Microcosmic orbit ear massage every night. Add facial + energy massage for 20 minutes.", image_url: "img url", video_url: "video url"})
conditions.save



users = User.new({email: "person2@icecream.com", password_digest: "password2"})
users.save



journals = Journal.new({user_id: 2, description: "Eye diagnosis and blood test still says anemic from some time ago.", image_url: "img url", video_url: "video url", health_routines: "Nothing but bananas.", bp_avg: "110/69", bp_annotations: "Could be from the excess fatigue and bed riddeness.", image_of_tongue: "tongue image url"})
journals.save

journals = Journal.new({user_id: 2, description: "Patient is more energetic than yesterday relatively speaking", image_url: "img url", video_url: "video url", health_routines: "More miso soup.", bp_avg: "120/75", bp_annotations: "Better than yesterday.", image_of_tongue: "tongue image url"})
journals.save



conditions = Condition.new({user_id: 2, name: "anemia", support: 0, treatment_retrospect: "Need to follow through with current treatment plan", treatment_plan: "A bunch of beets", image_url: "img url", video_url: "video url"})
conditions.save

conditions = Condition.new({user_id: 2, name: "fatigue", support: 0, treatment_retrospect: "Need to follow through with current treatment plan", treatment_plan: "More beets and exercise.", image_url: "img url", video_url: "video url"})
conditions.save










