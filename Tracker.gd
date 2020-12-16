extends Control

var playing = false
onready var Sin = $Audio/Sin
onready var Square = $Audio/Square
onready var Tri = $Audio/Triangle
onready var Gen = $Audio/Generic
onready var FD = $Popups/FileDialog

onready var setChan1 = $MarginContainer/VBoxContainer/ChannelInfo/MarginContainer3/HBoxContainer/Channel1/VBoxContainer/SetChannel
onready var setChan2 = $MarginContainer/VBoxContainer/ChannelInfo/MarginContainer3/HBoxContainer/Channel2/VBoxContainer/SetChannel
onready var setChan3 = $MarginContainer/VBoxContainer/ChannelInfo/MarginContainer3/HBoxContainer/Channel3/VBoxContainer/SetChannel
onready var setChan4 = $MarginContainer/VBoxContainer/ChannelInfo/MarginContainer3/HBoxContainer/Channel4/VBoxContainer/SetChannel

var sample_hz = 22050.0
var pulse_hz = 440.0
var sin_phase = 0.0
var square_phase = 0.0
var tri_phase = 0.0

var sin_playback: AudioStreamPlayback = null
var square_playback: AudioStreamPlayback = null
var tri_playback: AudioStreamPlayback = null
var gen_playback: AudioStreamPlayback = null

var filepathA = null
var filepathB = null
var filepathC = null
var filepathD = null

var prefixSetChannel = "Set Channel"

var pathSet = -1

func _fill_sin_buffer():
	var increment = pulse_hz / sample_hz
	
	var to_fill = sin_playback.get_frames_available()
	while to_fill > 0:
		sin_playback.push_frame(Vector2.ONE * sin(sin_phase * TAU))
		sin_phase = fmod(sin_phase + increment, 1.0)
		to_fill -= 1

func _fill_square_buffer():
	var increment = pulse_hz / sample_hz
	
	var to_fill = square_playback.get_frames_available()
	var max_filled = to_fill
	while to_fill > 0:
		square_playback.push_frame(Vector2.ONE*round(sin(square_phase * TAU)))
		square_phase = fmod(square_phase + increment, 1.0)
		to_fill -= 1

func _fill_triangle_buffer():
	var increment = pulse_hz / sample_hz
	
	var to_fill = tri_playback.get_frames_available()
	var max_filled = to_fill
	while to_fill > 0:
		tri_playback.push_frame(Vector2.ONE*round(tri_phase * TAU))
		tri_phase = fmod(tri_phase + increment, 1.0)
		to_fill -= 1

func _fill_noise_buffer():
	randomize()
	
	var to_fill = gen_playback.get_frames_available()
	var max_filled = to_fill
	while to_fill > 0:
		gen_playback.push_frame(Vector2.ONE*randf())
		to_fill -= 1

func _fill_buffers():
	if filepathA == null:
		_fill_sin_buffer()
	if filepathB == null:
		_fill_square_buffer()
	if filepathC == null:
		_fill_triangle_buffer()
	if filepathD == null:
		_fill_noise_buffer()

func _process(delta):
	_fill_buffers()

func _ready():
	set_datas()
	_fill_buffers()

func set_datas():
	Sin.stream.mix_rate = sample_hz
	sin_playback = Sin.get_stream_playback()
	Square.stream.mix_rate = sample_hz
	square_playback = Square.get_stream_playback()
	Tri.stream.mix_rate = sample_hz
	tri_playback = Tri.get_stream_playback()
	Gen.stream.mix_rate = sample_hz
	gen_playback = Gen.get_stream_playback()

func _on_PlayButton_pressed():
	playing = !playing
	play()

func play():
	if !playing:
		Tri.stop()
		Square.stop()
		Sin.stop()
		Gen.stop()
	else:
		Gen.play()

func play_square():
	if !playing:
		return

func _on_FileDialog_file_selected(path):
	var sfx = load(path)
	if pathSet == 0:
		filepathA = path
		Sin.stream = sfx
		setChan1.text = prefixSetChannel + " - " + path.get_file()
	if pathSet == 1:
		filepathB = path
		Square.stream = sfx
		setChan2.text = prefixSetChannel + " - " + path.get_file()
	if pathSet == 2:
		filepathC = path
		Tri.stream = sfx
		setChan3.text = prefixSetChannel + " - " + path.get_file()
	if pathSet == 3:
		filepathC = path
		Gen.stream = sfx
		setChan4.text = prefixSetChannel + " - " + path.get_file()
	pathSet = -1


func _on_SetChannel1_pressed():
	pathSet = 0
	FD.popup_centered()


func _on_SetChannel2_pressed():
	pathSet = 1
	FD.popup_centered()


func _on_SetChannel3_pressed():
	pathSet = 2
	FD.popup_centered()


func _on_SetChannel4_pressed():
	pathSet = 3
	FD.popup_centered()


func _on_ResetChannels_pressed():
	setChan1.text = prefixSetChannel
	setChan2.text = prefixSetChannel
	setChan3.text = prefixSetChannel
	setChan4.text = prefixSetChannel
	filepathA = null
	filepathB = null
	filepathC = null
	filepathD = null
	Sin.stream= AudioStreamGenerator.new()
	Square.stream = AudioStreamGenerator.new()
	Tri.stream = AudioStreamGenerator.new()
	Gen.stream = AudioStreamGenerator.new()
	set_datas()


func _on_Quit_pressed():
	get_tree().quit()
