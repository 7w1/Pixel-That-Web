extends Control

func _ready():
	$Buttons/MenuButton.disabled = true
	# Set panel content to menu

func _on_UpgradesButton_pressed():
	reenable_buttons()
	$Buttons/UpgradesButton.disabled = true
	# Set panel content to upgrades

func _on_PrestigeButton_pressed():
	reenable_buttons()
	$Buttons/PrestigeButton.disabled = true
	# Set panel content to prestige

func _on_AchivementsButton_pressed():
	reenable_buttons()
	$Buttons/AchievementsButton.disabled = true
	# Set panel content to achivements

func _on_StatsButton_pressed():
	reenable_buttons()
	$Buttons/StatsButton.disabled = true
	# Set panel content to stats

func _on_MenuButton_pressed():
	reenable_buttons()
	$Buttons/MenuButton.disabled = true
	# Set panel content to menu

func reenable_buttons():
	$Buttons/UpgradesButton.disabled = false
	$Buttons/PrestigeButton.disabled = false
	$Buttons/AchievementsButton.disabled = false
	$Buttons/StatsButton.disabled = false
	$Buttons/MenuButton.disabled = false
