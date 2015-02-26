from edl.edl import Parser
from pytimecode import PyTimeCode
import json

parser = Parser('29.97')
tc = PyTimeCode('29.97')

f = open('edit.edl')
edl = parser.parse(f)
f.close()

f = open("source_data.json")
source_data = json.load(f)
f.close()

#source_data = json.dumps(source_data, sort_keys=True, indent=4)

prev_name = ""
prev_out = 0

out_data = []

for event in edl.events:

	if event.next_event == None or event.clip_name != event.next_event.clip_name:

		name = event.clip_name
		
		tc.set_timecode( str(event.rec_end_tc) )
		end = tc.mins * 60 + tc.secs + (tc.frs / 29.97)

		print name + " - " + str(end)

		out_data.append({
			"url": source_data[str(name)]["url"],
			"end": end
		})

# export to json
with open('edl_data.json', 'w') as outfile:
	json.dump(out_data, outfile)