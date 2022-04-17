extends Node2D

export(PackedScene) var arp_bot
export(PackedScene) var bots_section
onready var section_manager = self.get_node("SectionManager")

var file_utils = preload("res://FileUtils.gd")
var server
var client
var bytes
var connection_status
var total_packets = 255
var packets_sent = 1
var received_data = ""
var arp_pid

var initial_bot_x_offset = -120
var initial_bot_y_offset = 40
var bot_x_offset = initial_bot_x_offset
var bot_y_offset = initial_bot_y_offset
var bot_x_step = 75
var bot_y_step = 75
var bots_per_row = 10
var bots_row_count = 0
var current_row = 1

# SECTION DATA
var current_section_id = 0

var hosts = []
var white_list = []
var white_list_initialized: bool = false

const SERVER_IP = "127.0.0.1"
const SERVER_PORT = 3000
const WHITE_LIST_FILE = "white-list.txt"

func _ready():
	self.server = TCP_Server.new()
	if self.server.listen(self.SERVER_PORT, self.SERVER_IP) == 0:
		print("Server started on port " + str(self.SERVER_PORT) + " with ip address " + str(self.SERVER_IP) + "!")
		self.set_process(true)
		self.initialize_white_list()
		self.section_manager.add_new_section(self.bots_section.instance(), $MonitorLayer)
		#self.run_arp(["arp.py", "--bcast"])

func run_arp(options):
	self.arp_pid = OS.execute("python", options, false)

func _process(delta):
	if self.server.is_connection_available():
		self.client = self.server.take_connection()
		self.connection_status = self.client.get_status()
		if self.connection_status == StreamPeerTCP.STATUS_CONNECTED:
			self.bytes = self.client.get_available_bytes()
			if self.bytes > 0:
				self.handle_received_data()

func handle_received_data():
	self.received_data = self.client.get_string(self.bytes).split(" - ", false, 0)
	if self.received_data[0] == "Packet":
		self.packets_sent = int(self.received_data[1])
		$MonitorLayer/PacketsSent.text = "Packets sent " + str(self.packets_sent)
		if self.packets_sent == self.total_packets:
			$MonitorLayer/Status.text = "Done!"
			#OS.kill(self.arp_pid)
	else:
		self.add_host(self.received_data)
		#print(self.hosts)
	
func add_host(data):
	var host = {"ipaddr":data[0], "hwaddr":data[1], "trusted":false}
	if self.white_list_initialized:
		for entry in self.white_list:
			var _entry = entry.split("-", false, 0)
			if _entry[0] == host["ipaddr"] and _entry[1] == host["hwaddr"]:
				host['trusted'] = true

	if not self.has_host(host):
		self.hosts.append(host)
		self.current_section.add_child(self.arp_bot.instance().set_data(host, Vector2(self.bot_x_offset, self.bot_y_offset)))
		self.bot_x_offset += self.bot_x_step
		self.bots_row_count += 1
		if self.bots_row_count == self.bots_per_row:
			self.bots_row_count = 0
			self.bot_x_offset = self.initial_bot_x_offset
			self.bot_y_offset += self.bot_y_step
			self.current_row += 1
		
		if self.current_row > 3:
			self.current_row = 1
			self.bot_y_offset = self.initial_bot_y_offset

func has_host(host):
	for entry in self.hosts:
		if entry['ipaddr'] == host['ipaddr'] and entry['hwaddr'] == host['hwaddr']:
			return true
	return false

func initialize_white_list():
	var file = file_utils.load_file(WHITE_LIST_FILE)
	if file != null:
		while not file.eof_reached():
			var entry = file.get_line().strip_edges()
			if entry.length() > 0:
				self.white_list.append(entry)
				if not self.white_list_initialized:
					self.white_list_initialized = true
