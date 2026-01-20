import riak
import random as rnd

# client = riak.RiakClient()
client = riak.RiakClient(protocol='http', host='172.19.3.36', http_port=8098)

bucket = client.bucket('rooms')
STYLES = ['single', 'double', 'queen', 'king', 'suite']

# Create 100 floors to the building
for floor in range(1, 100):
    current_room_block = floor * 100
    # Put 100 rooms on each floor (huge hotel!)
    for room in range(1, 100):
        # Create a unique room number as the key
        room_unq = str(current_room_block + room)
        room_unq_str = 'floor' + str(floor) + 'room' + str(room)
        print(room_unq_str)
        # Randomly grab a room style, and make up a capacity
        style = STYLES[rnd.randint(0, len(STYLES)-1)]
        capacity = rnd.randint(1, 8)
        # Store the room information as a JSON value
        obj = bucket.new(room_unq)
        obj.content_type = "application/json"
        obj.data = {'style': style, 'capacity': capacity, 'floor_no': floor, 'room_no': room}
        obj.store()

# delete keys
for keys in bucket.stream_keys():
    print(keys)
    for key in keys:
        bucket.delete(key)


query = client.add(bucket)
query.map("function(v) { var parsed_data = JSON.parse(v.values[0].data); var data = {}; data[parsed_data.style] = parsed_data.capacity; return [data];}")
query.reduce("function(v) { var totals = {}; for (var i in v) { for(var style in v[i]) { if( totals[style] ) totals[style] += v[i][style]; else totals[style] = v[i][style]; } }return [totals];}")

for result in query.run():
    print(result)
