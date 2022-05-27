extends VBoxContainer


func _process(_delta):
	$Export.rect_size.x = self.rect_size.x
	$Exportbox.rect_size.x = self.rect_size.x
	$Import.rect_size.x = self.rect_size.x
	$Importbox.rect_size.x = self.rect_size.x
