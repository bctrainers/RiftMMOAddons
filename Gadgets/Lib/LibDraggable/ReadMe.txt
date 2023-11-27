LibDraggable exists to make windows draggable.

HOW IT WORKS:
	Library.LibDraggable.dragify(window, callback)

LibDraggable checks for mousedowns in the border of the window
(as in window:GetBorder()).  If it has detected one, but hasn't
detected a LeftUp event, it intercepts mousemoves.

There used to be special hooks to call the previous MouseMove or LeftUp
functions, but under the new event model that's not needed -- if you
provide functions using the old model, they should still work, and if
you use the new model, it should also still work.

If you provide a callback function, it'll be called as
	callback(window, x, y)

whenever there's a move.
