As i imagine, one doctor can have many appointments, one appointment belongs to doctor, and appointment belongs to patient.
At the same time patient can have many appointments, the same as doctor. And doctor has many working hours.

So, summarizing following statements we should have following database scheme:

* `table "appointments", fields:
   "appointment_date" datetime
   "doctor_id" bigint  null: false
   "patient_id" bigint null: false`

* `table "doctors", fileds:
   "name" string
   "specialty" string`

* `table "patients", fields:
   "name" string
   "contact_info" string`

* `table "working_hours", fields:
   "doctor_id" bigint null: false
   "day_of_week" integer
   "start_time" time
   "end_time" time`