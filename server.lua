--[[
	Made by Yeleha & waves

	This file is part of 3DEditor.

	3DEditor is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

	3DEditor is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along with 3DEditor. If not, see https://github.com/Derbosik/3DEditor/blob/main/LICENSE. 
]]

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
