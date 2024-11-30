--[[
	Made by Yeleha (YelehaUwU)

	This file is part of 3DEditor.

	3DEditor is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

	3DEditor is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along with 3DEditor. If not, see https://github.com/YelehaUwU/3DEditor/blob/main/LICENSE. 
]]

function startEdit(element, disableMoving, disableRotate, disableScale, controller)
	if isElement(element) and isElement(controller) then triggerClientEvent(controller, "3DEditor:startEdit", controller, element, disableMoving and true or false, disableRotate and true or false, disableScale and true or false, sourceResource) end
end

function savedObject(sourceResource, element, cx, cy, cz, rx, ry, rz, sx, sy, sz)
	setElementPosition(element, cx, cy, cz)
	setElementRotation(element, rx, ry, rz)
	setObjectScale(element, sx, sy, sz)
end
addEvent("3DEditor:savedObject", true)
addEventHandler("3DEditor:savedObject", root, savedObject)

function savedObject(sourceResource, element, cx, cy, cz, rx, ry, rz, sx, sy, sz)
	exports[pAttachName]:setPositionOffset(element, cx, cy, cz)
	exports[pAttachName]:setRotationOffset(element, rx, ry, rz)
	setObjectScale(element, sx, sy, sz)
end
addEvent("3DEditor:savedAttachedObject", true)
addEventHandler("3DEditor:savedAttachedObject", root, savedObject)
