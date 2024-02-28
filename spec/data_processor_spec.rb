require "csv"
require "data_processor"

RSpec.describe DataProcessor do
  describe ".create_people_from_csv_data" do
    it "combines two CSV parsed inputs into one array of Person" do
      people_data = CSV.parse(<<~CSV, headers: true)
        Email,Eligible for in-hours primary?,Can do in-hours secondary?,Eligible for on-call primary?,Eligible for on-call secondary?,Should be scheduled for on-call?
        a@a.com,Yes,Yes,Yes,Yes,Yes
      CSV
      responses_data = CSV.parse(<<~CSV, headers: true)
        Timestamp,Email address,Have you been given an exemption from on call?,Do you have any non working days? [Non working day(s)],What team/area are you in (or will be in when this rota starts)?,"If you work different hours to the 9.30am-5.30pm 2nd line shifts, please state your hours",Week commencing 01/04/2024,Week commencing 08/04/2024,Need to elaborate on any of the above?
        timestamp,a@a.com,"","Wed,Fri",Platform,,"",Not available for on-call over the weekend
      CSV

      expect(Person).to receive(:new).with({
        email: "a@a.com",
        team: "Platform",
        non_working_days: %w[Wednesday Friday],
        forbidden_in_hours_days: [],
        forbidden_on_call_days: ["13/04/2024", "14/04/2024"],
        can_do_roles: %i[
          inhours_primary
          inhours_secondary
          inhours_primary_standby
          inhours_secondary_standby
          oncall_primary
          oncall_secondary
        ],
      })

      described_class.create_people_from_csv_data(people_data, responses_data)
    end
  end
end
