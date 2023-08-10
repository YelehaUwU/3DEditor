function startEdit(element, controller)
	if isElement(element) and isElement(controller) then triggerClientEvent(controller, "editor:startEdit", controller, element) end
end

function savedObject(sourceResource, element, cx, cy, cz, rx, ry, rz, sx, sy, sz)
	if not isElementLocal(element) then
		setElementPosition(element, cx, cy, cz)
		setElementRotation(element, rx, ry, rz)
		setObjectScale(element, sx, sy, sz)
	end
end
addEvent("editor:savedObject", true)
addEventHandler("editor:savedObject", root, savedObject)