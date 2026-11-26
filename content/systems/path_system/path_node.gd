@abstract
class_name PathNode
extends Node2D


@export 
var grid_pos := Vector2i.ZERO:
    set(pos):
        grid_pos = pos
        position = Settings.get_global_pos(grid_pos)
        return

@export
var node_link : PathNodeLink = PathNodeLink.LINK_POS_X


enum PathNodeLink {
    LINK_POS_X = PathSystem.LINK_POS_X,
    LINK_POS_Y = PathSystem.LINK_POS_Y,
    LINK_NEG_X = PathSystem.LINK_NEG_X,
    LINK_NEG_Y = PathSystem.LINK_NEG_Y,
}
