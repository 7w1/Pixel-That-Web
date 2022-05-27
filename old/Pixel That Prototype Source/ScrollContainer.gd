extends ScrollContainer

func _process(_delta):
	$RichTextLabel.rect_size = Vector2(self.rect_size.x-8, self.rect_size.y)
