extends Control

@onready var players = [
	$PlayersContainer/TopRowContainer/Player1,
	$PlayersContainer/TopRowContainer/Player2,
	$PlayersContainer/BottomRowContainer/Player3,
	$PlayersContainer/BottomRowContainer/Player4
]
@onready var player_scores = [
	$PlayersContainer/TopRowContainer/Player1/ScoreContainer/ScoreMargin/ScoreText,
	$PlayersContainer/TopRowContainer/Player2/ScoreContainer2/ScoreMargin/ScoreText,
	$PlayersContainer/BottomRowContainer/Player3/ScoreContainer3/ScoreMargin/ScoreText,
	$PlayersContainer/BottomRowContainer/Player4/ScoreContainer4/ScoreMargin/ScoreText
]
@onready var spell_panels = [
	$PlayersContainer/TopRowContainer/Player1/Spell,
	$PlayersContainer/TopRowContainer/Player2/Spell,
	$PlayersContainer/BottomRowContainer/Player3/Spell,
	$PlayersContainer/BottomRowContainer/Player4/Spell
]
@onready var score_announce = $ScoreAnnouncePanel/AnnounceMargin/ScoreAnnounceText
@onready var incap_indicators = $IncapIndicators
@export var icon_fireball: Texture2D
@export var icon_shield: Texture2D

func _ready() -> void:
	init_hud()
	for c in get_tree().get_nodes_in_group("spell_caster"):
		var pn := 0
		if c is Node and c.has_variable("player_num"):
			pn = c.player_num
		elif c.has_method("get_player_num"):
			pn = c.get_player_num()
		else:
			continue

		var player_num := int(pn)

		if c.has_signal("spell_changed"):
			c.spell_changed.connect(func(id: int):
				var icon := _spell_icon_by_id(id)
				hud_set_spell(player_num, icon)
			)

func update_score(player_id: int, new_score: int):
	player_scores.get(player_id).text = str(new_score)
	
func init_hud():
	#reset score texts
	reset_scores_ui()
	#reset score announcement
	reset_score_announce()
	#hide incapicated indicators
	reset_incap_ind()
	for sp in spell_panels:
		sp.hide()
		var icon_node := sp.get_node_or_null("Icon") as TextureRect
		if icon_node:
			icon_node.texture = null

func announce_score(player_id: int):
	score_announce.get_parent().get_parent().show()
	score_announce.text = "Player " + str(player_id) + " Scored!"

func indicate_player_incapicated(player_id: int, is_down: bool):
	if is_down:
		incap_indicators.get_child(player_id).show()
	else:
		incap_indicators.get_child(player_id).hide()

func reset_score_announce():
	score_announce.get_parent().get_parent().hide()
	score_announce.text = "Scored!"

func reset_scores_ui():
	for score in player_scores:
		score.text = "0"

func reset_incap_ind():
	for indi in incap_indicators.get_children():
		indi.hide()

func enable_player_icons(players_in: Array[bool]):
	print(players_in)
	for p in players_in:
		if p:
			players.get(players_in.find(p)).show()

func _get_panel(player_num: int) -> Control:
	if player_num < 1 or player_num > spell_panels.size(): 
		return null
	return spell_panels[player_num - 1]

func hud_set_spell(player_num: int, icon: Texture2D) -> void:
	var p := _get_panel(player_num)
	if p == null: return
	var icon_node := p.get_node_or_null("Icon") as TextureRect
	if icon_node:
		icon_node.texture = icon
	if icon == null:
		p.hide()
	else:
		p.show()

func _spell_icon_by_id(id: int) -> Texture2D:
	match id:
		SpellPickup.SpellID.FIREBALL: return icon_fireball
		SpellPickup.SpellID.SHIELD:   return icon_shield
		_: return null
