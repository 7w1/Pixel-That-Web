extends Panel

func _ready():
	hide_panels()
	$Upgrades.show()

func _process(_delta):
	self.rect_size.y = OS.get_window_size().y
	self.rect_size.x = OS.get_window_size().x-(750*OS.get_window_size().y/750)
	self.rect_position.x = -1*self.rect_size.x+40
	
	$Upgrades/ScrollContainer/Upgrades.rect_min_size.x = (self.rect_size.x-16)/(self.rect_size.x-16)/750
	$Upgrades/ScrollContainer/Upgrades.rect_scale = Vector2((self.rect_size.x-16)/750, (self.rect_size.x-16)/750)
	$Achievements/VBoxContainer/ScrollContainer.rect_min_size.y = OS.get_window_size().y - 128
	$Achievements/VBoxContainer.rect_size.x = OS.get_window_size().x-(750*OS.get_window_size().y/750)
	$Achievements/VBoxContainer/ScrollContainer/FlexGridContainer.rect_min_size.x = $Achievements/VBoxContainer.rect_size.x-12

func _on_UpgradesButton_pressed():
	hide_panels()
	$Upgrades.show()

func _on_PrestigeButton_pressed():
	hide_panels()
	$Prestige.show()

func _on_AchivementsButton_pressed():
	hide_panels()
	$Achievements.show()

func _on_StatsButton_pressed():
	hide_panels()
	$Stats.show()

func _on_MenuButton_pressed():
	hide_panels()
	$Menu.show()
	
func hide_panels():
	$Upgrades.hide()
	$Prestige.hide()
	$Achievements.hide()
	$Stats.hide()
	$Menu.hide()
