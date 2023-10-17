# README

To run the application:
* clone the repository using the command `git@github.com:valeronpCom/teladoc-tech-assignment.git`
* go to the application folder using the command `cd teladoc-tech-assignment`
* run these commands to setup everything
    * `gem install bundler`
    * `bin/setup`
* run the application using `rails s` command
* go to `http://localhost:3000/`

Because it is an RESTful API, the application works in the following way:
* to see doctor's working hours and availability you need to do the following GET request:
  * `http://localhost:3000/doctors/:doctor_id/appointments?day_of_week=1`
* to make an appointment you should do the following POST request:
  * `http://localhost:3000/doctors/:doctor_id/appointments/` with following JSON data:
    * `{
      "appointment": {
      "appointment_date": "2023-10-17T13:30:00+02:00",
      "patient_id": 1
      }
      }`
    where you set date and time of appointment. By default it takes your timezone, but you can set it up, what was done there by +02:00.
    And you should set the id of patient who wants to make an appointment. In case of success you will see the data of your appointment.
* to edit the appointment you should do the following PUT/PATCH request:
  * `http://localhost:3000/doctors/:doctor_id/appointments/:id` with following JSON data:
    * `{
      "appointment": {
      "appointment_date": "2023-10-17T15:30:00+02:00"
      }
      }`
    In request additionally to create URL we add an ID of already created appointment. In case of success you will see updated data of your appointment.
* delete the appointment you should do the following DELETE request:
  * `http://localhost:3000/doctors/:doctor_id/appointments/:id`
  In case of success you won't receive anything and you will be able to see that one more slot became empty.
