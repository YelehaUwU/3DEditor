--[[
	Made by Yeleha (YelehaUwU)

	This file is part of 3DEditor.

	3DEditor is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

	3DEditor is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along with 3DEditor. If not, see https://github.com/YelehaUwU/3DEditor/blob/main/LICENSE.
]]

-- Don't touch these if you don't know what you're doing.

-- Constants
local sx, sy = guiGetScreenSize()
local XYZlength = 0.5
local sourceResElement
local element

-- Edit Mode Variables
local undoStack = {}
local redoStack = {}
local pAttached

-- Control State Variables
local disabledMoving
local disabledRotating
local disabledScaling

-- Confirmation Flags
local isSavingConfirmed = false
local isTrashingConfirmed = false

-- New mouse system
local lastCursorX, lastCursorY
local isMoving = false
local moveAxis = nil
local sensitivityMove = 0.002
local sensitivityRotate = 1
local sensitivityScale = 0.05

function startEdit(elementik, disableMoving, disableRotate, disableScale, sourceRes)
	element = elementik

	if not isElement(element) or getElementType(element) == "player" or getElementType(element) == "vehicle" or isElement(info) then
		return false
	end

	sourceResElement = sourceRes or sourceResource
	disabledMoving = disableMoving
	disabledRotating = disableRotate
	disabledScaling = disableScale

	local dx, dy, dz = getElementPosition(element)
	local drx, dry, drz = getElementRotation(element)
	local dsx, dsy, dsz = getObjectScale(element)

	local px, py, pz
	local prx, pry, prz

	if getResourceFromName(pAttachName) and getResourceState(getResourceFromName(pAttachName)) == "running" and exports[pAttachName]:isAttached(element) then
		pAttached = true
		local details = exports[pAttachName]:getDetails(element)
		px, py, pz = details[4], details[5], details[6]
		prx, pry, prz = details[7], details[8], details[9]
	end

	bMove = guiCreateStaticImage(770 / 1920 * sx, 900 / 1080 * sy, 70 / 1920 * sx, 70 / 1080 * sy, "files/move.png",
		false)
	guiSetAlpha(bMove, disabledMoving and 0.25 or 1)

	bRotate = guiCreateStaticImage(850 / 1920 * sx, 900 / 1080 * sy, 70 / 1920 * sx, 70 / 1080 * sy, "files/rotate.png",
		false)
	guiSetAlpha(bRotate, disabledRotating and 0.25 or 1)

	bSize = guiCreateStaticImage(930 / 1920 * sx, 900 / 1080 * sy, 70 / 1920 * sx, 70 / 1080 * sy, "files/size.png",
		false)
	guiSetAlpha(bSize, disabledScaling and 0.25 or 1)

	bBin = guiCreateStaticImage(1010 / 1920 * sx, 900 / 1080 * sy, 70 / 1920 * sx, 70 / 1080 * sy, "files/bin.png", false)
	bSave = guiCreateStaticImage(1090 / 1920 * sx, 900 / 1080 * sy, 70 / 1920 * sx, 70 / 1080 * sy, "files/save.png",
		false)

	info = guiCreateLabel(780 / 1920 * sx, 975 / 1080 * sy, 500 / 1920 * sx, 80 / 1080 * sy,
		"Hold down SHIFT to move faster and hold down ALT to move slower\nHold down Right Mouse to move freely", false)

	-- Determine the edit mode and start the corresponding event handler
	if not isEventHandlerAdded("onClientRender", root, drawControls) then
		if not disabledMoving then
			editing = true
			guiSetAlpha(bMove, 0.75)
		elseif not disabledRotating then
			rotating = true
			guiSetAlpha(bRotate, 0.75)
		elseif not disabledScaling then
			sizing = true
			guiSetAlpha(bSize, 0.75)
		else
			return false
		end
		addEventHandler("onClientRender", root, drawControls)
	end

	showCursor(true)

	function onClick(button, state)
		if button == "left" and state == "up" then
			if source == bMove and not disabledMoving then
				-- Set the information text and reset confirmation flags
				guiSetText(info,
					"Hold down SHIFT to move faster and hold down ALT to move slower\nHold down Right Mouse to move freely")
				isSavingConfirmed = false
				isTrashingConfirmed = false

				-- Handle edit mode transitions
				if not disabledRotating then
					guiSetAlpha(bRotate, 1)
				end
				if not disabledScaling then
					guiSetAlpha(bSize, 1)
				end
				rotating = false
				editing = true
				sizing = false
			elseif source == bRotate and not disabledRotating then
				-- Set the information text and reset confirmation flags
				guiSetText(info,
					"Hold down SHIFT to move faster and hold down ALT to move slower\nHold down Right Mouse to move freely")
				isSavingConfirmed = false
				isTrashingConfirmed = false

				-- Handle edit mode transitions
				if not disabledMoving then
					guiSetAlpha(bMove, 1)
				end
				if not disabledScaling then
					guiSetAlpha(bSize, 1)
				end
				editing = false
				rotating = true
				sizing = false
			elseif source == bSize and not disabledScaling then
				-- Set the information text and reset confirmation flags
				guiSetText(info,
					"Hold down SHIFT to move faster and hold down ALT to move slower\nHold down Right Mouse to move freely")
				isSavingConfirmed = false
				isTrashingConfirmed = false

				-- Handle edit mode transitions
				if not disabledMoving then
					guiSetAlpha(bMove, 1)
				end
				if not disabledRotating then
					guiSetAlpha(bRotate, 1)
				end
				editing = false
				rotating = false
				sizing = true
			elseif source == bBin then
				if isElement(element) then
					if not isTrashingConfirmed then
						guiSetText(info, "Are you sure you want to trash the changes?")
						isTrashingConfirmed = true
					else
						setObjectScale(element, dsx, dsy, dsz)
						if pAttached then
							exports[pAttachName]:setPositionOffset(element, px, py, pz)
							exports[pAttachName]:setRotationOffset(element, prx, pry, prz)
							if not isElementLocal(element) then
								triggerServerEvent("3DEditor:savedAttachedObject",
									resourceRoot, sourceResElement, element, px, py, pz, prx, pry, prz, dsx, dsy, dsz)
							end
							triggerEvent("3DEditor:savedAttachedObject", localPlayer, sourceResElement, element, px, py,
								pz, prx, pry, prz, dsx, dsy, dsz)
						else
							setElementPosition(element, dx, dy, dz)
							setElementRotation(element, drx, dry, drz)
							if not isElementLocal(element) then
								triggerServerEvent("3DEditor:savedObject", resourceRoot,
									sourceResElement, element, dx, dy, dz, drx, dry, drz, dsx, dsy, dsz)
							end
							triggerEvent("3DEditor:savedObject", localPlayer, sourceResElement, element, dx, dy, dz, drx,
								dry, drz, dsx, dsy, dsz)
						end
						closeMenu()
					end
				end
			elseif source == bSave then
				if isElement(element) then
					if not isSavingConfirmed then
						guiSetText(info, "Are you sure you want to save the changes?")
						isSavingConfirmed = true
					else
						local sx2, sy2, sz2 = getObjectScale(element)
						if pAttached then
							local details = exports[pAttachName]:getDetails(element)
							if not isElementLocal(element) then
								triggerServerEvent("3DEditor:savedAttachedObject", resourceRoot, sourceResElement,
									element, details[4], details[5], details[6], details[7], details[8], details[9], sx2,
									sy2, sz2)
							end
							triggerEvent("3DEditor:savedAttachedObject", localPlayer, sourceResElement, element,
								details[4], details[5], details[6], details[7], details[8], details[9], sx2, sy2, sz2)
						else
							local cx, cy, cz = getElementPosition(element)
							local rx, ry, rz = getElementRotation(element)
							if not isElementLocal(element) then
								triggerServerEvent("3DEditor:savedObject", localPlayer, sourceResElement, element, cx,
									cy, cz, rx, ry, rz, sx2, sy2, sz2)
							end
							triggerEvent("3DEditor:savedObject", localPlayer, sourceResElement, element, cx, cy, cz, rx,
								ry, rz, sx2, sy2, sz2)
						end
						closeMenu()
					end
				end
			end
		end
	end

	if not isEventHandlerAdded("onClientGUIClick", root, onClick) then
		addEventHandler("onClientGUIClick", root, onClick)
	end
end

addEvent("3DEditor:startEdit", true)
addEventHandler("3DEditor:startEdit", root, startEdit)

function drawControls()
	if (isElement(element)) then
		dx, dy, dz = getPositionFromElementOffset(element, XYZlength, 0, 0)
		fx, fy, fz = getPositionFromElementOffset(element, 0, XYZlength, 0)
		ux, uy, uz = getPositionFromElementOffset(element, 0, 0, XYZlength)
		px, py, pz = getElementPosition(element)

		if (editing) then
			xImage = "x"
			yImage = "y"
			zImage = "z"
		elseif (rotating) then
			xImage = "xr"
			yImage = "yr"
			zImage = "zr"
		elseif (sizing) then
			xImage = "xs"
			yImage = "ys"
			zImage = "zs"
		end

		mX, mY = getScreenFromWorldPosition(px, py, pz)
		if (mX and mY) then
			ix, iy = getScreenFromWorldPosition(dx, dy, dz, 1)
			ix2, iy2 = getScreenFromWorldPosition(fx, fy, fz, 1)
			ix3, iy3 = getScreenFromWorldPosition(ux, uy, uz, 1)

			local red = tocolor(255, 0, 0, 230)
			local green = tocolor(0, 255, 0, 230)
			local blue = tocolor(0, 0, 255, 230)

			if (ix and iy and ix2 and iy2 and ix3 and iy3) then
				if isMouseInPosition(ix - 10, iy - 10, 20, 20) or x then
					red = tocolor(150, 0, 0, 255)
				elseif isMouseInPosition(ix2 - 10, iy2 - 10, 20, 20) or y then
					green = tocolor(0, 150, 0, 255)
				elseif isMouseInPosition(ix3 - 10, iy3 - 10, 20, 20) or z then
					blue = tocolor(0, 0, 150, 255)
				end

				dxDrawLine(ix, iy, mX, mY, red, 2, false)
				dxDrawImage(ix - 10, iy - 10, 20, 20, 'files/' .. xImage .. '.png', 0, 0, 0, tocolor(255, 255, 255, 230),
					false)
				dxDrawText("X", ix + 25, iy - 10, ix + 25, iy + 10, tocolor(255, 255, 255, 230), 0.65, "bankgothic",
					"center", "center", false)

				dxDrawLine(ix2, iy2, mX, mY, green, 2, false)
				dxDrawImage(ix2 - 10, iy2 - 10, 20, 20, 'files/' .. yImage .. '.png', 0, 0, 0,
					tocolor(255, 255, 255, 230), false)
				dxDrawText("Y", ix2 + 25, iy2 - 10, ix2 + 25, iy2 + 10, tocolor(255, 255, 255, 230), 0.65, "bankgothic",
					"center", "center", false)

				dxDrawLine(ix3, iy3, mX, mY, blue, 2, false)
				dxDrawImage(ix3 - 10, iy3 - 10, 20, 20, 'files/' .. zImage .. '.png', 0, 0, 0,
					tocolor(255, 255, 255, 230), false)
				dxDrawText("Z", ix3 + 25, iy3 - 10, ix3 + 25, iy3 + 10, tocolor(255, 255, 255, 230), 0.65, "bankgothic",
					"center", "center", false)
			end
		end
	else
		closeMenu(true)
	end
end

addEventHandler("onClientMouseEnter", root,
	function()
		if source == bMove or source == bRotate or source == bSize or source == bBin or source == bSave then
			if source == bMove and (editing or disabledMoving) then return end
			if source == bRotate and (rotating or disabledRotating) then return end
			if source == bSize and (sizing or disabledScaling) then return end
			guiSetAlpha(source, 0.75)
		end
	end
)

addEventHandler("onClientMouseLeave", root,
	function()
		if source == bMove or source == bRotate or source == bSize or source == bBin or source == bSave then
			guiSetText(info,
				"Hold down SHIFT to move faster and hold down ALT to move slower\nHold down Right Mouse to move freely")
			isSavingConfirmed = false
			isTrashingConfirmed = false
			if source == bMove and editing then return end
			if source == bRotate and rotating then return end
			if source == bSize and sizing then return end
			if source == bMove and disabledMoving then
				guiSetAlpha(source, 0.25)
				return
			end
			if source == bRotate and disabledRotating then
				guiSetAlpha(source, 0.25)
				return
			end
			if source == bSize and disabledScaling then
				guiSetAlpha(source, 0.25)
				return
			end
			guiSetAlpha(source, 1)
		end
	end
)

function closeMenu()
	redoStack = {}
	undoStack = {}
	pAttached = false

	removeEventHandler("onClientRender", root, drawControls)
	removeEventHandler("onClientCursorMove", root, cursorMove)
	removeEventHandler("onClientGUIClick", root, onClick)

	isMoving = false
	moveAxis = nil
	lastCursorX = nil
	lastCursorY = nil

	rotating = false
	editing = true
	sizing = false
	element = nil

	disabledMoving = false
	disabledRotating = false
	disabledScaling = false

	isSavingConfirmed = false
	isTrashingConfirmed = false

	destroyElement(bSize)
	destroyElement(bRotate)
	destroyElement(bMove)
	destroyElement(bBin)
	destroyElement(bSave)
	destroyElement(info)
	showCursor(false)
end

function click(button, state, absoluteX, absoluteY)
	if not isElement(element) then return end

	if state == "down" and getKeyState(keyDragger) then
		if ix and iy and ix2 and iy2 and ix3 and iy3 then
			if isMouseInPosition(ix - 10, iy - 10, 20, 20) then
				moveAxis = "x"
				isMoving = true
			elseif isMouseInPosition(ix2 - 10, iy2 - 10, 20, 20) then
				moveAxis = "y"
				isMoving = true
			elseif isMouseInPosition(ix3 - 10, iy3 - 10, 20, 20) then
				moveAxis = "z"
				isMoving = true
			end

			if isMoving then
				lastCursorX, lastCursorY = nil, nil
				setElementAlpha(localPlayer, 150)
				setCursorAlpha(0)
				if not isEventHandlerAdded("onClientCursorMove", root, cursorMove) then
					addEventHandler("onClientCursorMove", root, cursorMove)
				end
			end
		end
	elseif getKeyState("mouse2") then
		showCursor(false)
	elseif state == "up" then
		if isMoving then
			isMoving = false
			moveAxis = nil
			setElementAlpha(localPlayer, 255)
			setCursorAlpha(255)
			removeEventHandler("onClientCursorMove", root, cursorMove)
		end
	end
end

addEventHandler("onClientClick", root, click)

function cursorRestore(button, press)
	if isElement(element) and button == "mouse2" and not press then
		showCursor(true)
	end
end

addEventHandler("onClientKey", root, cursorRestore)

function cursorMove(_, _, currentX, currentY)
	if not (isElement(element) and getKeyState(keyDragger) and isMoving) then
		return
	end

	if not lastCursorX then
		lastCursorX, lastCursorY = currentX, currentY
		return
	end

	local deltaX = currentX - lastCursorX
	local deltaY = currentY - lastCursorY

	-- Use X delta for X/Y axes, Y delta for Z axis
	local delta = (moveAxis == "z") and -deltaY or deltaX

	local sensitivity = sensitivityMove
	if editing then
		sensitivity = sensitivityMove * (getKeyState("lshift") and 4 or getKeyState("lalt") and 0.25 or 1)
	elseif rotating then
		sensitivity = sensitivityRotate * (getKeyState("lshift") and 2 or getKeyState("lalt") and 0.5 or 1)
	elseif sizing then
		sensitivity = sensitivityScale * (getKeyState("lshift") and 2 or getKeyState("lalt") and 0.25 or 1)
	end

	if pAttached and exports[pAttachName]:isAttached(element) then
		local details = exports[pAttachName]:getDetails(element)
		local px, py, pz = details[4], details[5], details[6]
		local rx, ry, rz = details[7], details[8], details[9]

		if editing then
			if moveAxis == "x" then
				exports[pAttachName]:setPositionOffset(element, px + delta * sensitivity, py, pz)
			elseif moveAxis == "y" then
				exports[pAttachName]:setPositionOffset(element, px, py + delta * sensitivity, pz)
			elseif moveAxis == "z" then
				exports[pAttachName]:setPositionOffset(element, px, py, pz + delta * sensitivity)
			end
		elseif rotating then
			if moveAxis == "x" then
				exports[pAttachName]:setRotationOffset(element, rx + delta * sensitivity, ry, rz)
			elseif moveAxis == "y" then
				exports[pAttachName]:setRotationOffset(element, rx, ry + delta * sensitivity, rz)
			elseif moveAxis == "z" then
				exports[pAttachName]:setRotationOffset(element, rx, ry, rz + delta * sensitivity)
			end
		elseif sizing then
			local sx, sy, sz = getObjectScale(element)
			if moveAxis == "x" then
				setObjectScale(element, sx + delta * sensitivity, sy, sz)
			elseif moveAxis == "y" then
				setObjectScale(element, sx, sy + delta * sensitivity, sz)
			elseif moveAxis == "z" then
				setObjectScale(element, sx, sy, sz + delta * sensitivity)
			end
		end
	else
		local px, py, pz = getElementPosition(element)
		local rx, ry, rz = getElementRotation(element)

		if editing then
			if moveAxis == "x" then
				setElementPosition(element, px + delta * sensitivity, py, pz)
			elseif moveAxis == "y" then
				setElementPosition(element, px, py + delta * sensitivity, pz)
			elseif moveAxis == "z" then
				setElementPosition(element, px, py, pz + delta * sensitivity)
			end
		elseif rotating then
			if moveAxis == "x" then
				setElementRotation(element, rx + delta * sensitivity, ry, rz)
			elseif moveAxis == "y" then
				setElementRotation(element, rx, ry + delta * sensitivity, rz)
			elseif moveAxis == "z" then
				setElementRotation(element, rx, ry, rz + delta * sensitivity)
			end
		elseif sizing then
			local sx, sy, sz = getObjectScale(element)
			if moveAxis == "x" then
				setObjectScale(element, sx + delta * sensitivity, sy, sz)
			elseif moveAxis == "y" then
				setObjectScale(element, sx, sy + delta * sensitivity, sz)
			elseif moveAxis == "z" then
				setObjectScale(element, sx, sy, sz + delta * sensitivity)
			end
		end
	end

	lastCursorX, lastCursorY = currentX, currentY
end

function stateControls()
	if element then
		local currentState = {
			position = { getElementPosition(element) },
			rotation = { getElementRotation(element) },
			scale = { getObjectScale(element) }
		}
		if pAttached then
			local details = exports[pAttachName]:getDetails(element)
			currentState = {
				position = { details[4], details[5], details[6] },
				rotation = { details[7], details[8], details[9] },
				scale = { getObjectScale(element) }
			}
		end
		if #undoStack == 0 or not areStatesEqual(currentState, undoStack[#undoStack]) then
			table.insert(undoStack, currentState)
		end
	end
end

function undo()
	if element and #undoStack > 0 then
		local currentState = {
			position = { getElementPosition(element) },
			rotation = { getElementRotation(element) },
			scale = { getObjectScale(element) }
		}
		if pAttached then
			local details = exports[pAttachName]:getDetails(element)
			currentState = {
				position = { details[4], details[5], details[6] },
				rotation = { details[7], details[8], details[9] },
				scale = { getObjectScale(element) }
			}
		end
		table.insert(redoStack, currentState)

		local previousState = table.remove(undoStack)
		if pAttached then
			exports[pAttachName]:setPositionOffset(element, unpack(previousState.position))
			exports[pAttachName]:setRotationOffset(element, unpack(previousState.position))
		else
			setElementPosition(element, unpack(previousState.position))
			setElementRotation(element, unpack(previousState.rotation))
		end
		setObjectScale(element, unpack(previousState.scale))
	end
end

function redo()
	if element and #redoStack > 0 then
		local currentState = {
			position = { getElementPosition(element) },
			rotation = { getElementRotation(element) },
			scale = { getObjectScale(element) }
		}
		if pAttached then
			local details = exports[pAttachName]:getDetails(element)
			currentState = {
				position = { details[4], details[5], details[6] },
				rotation = { details[7], details[8], details[9] },
				scale = { getObjectScale(element) }
			}
		end
		table.insert(undoStack, currentState)

		local nextState = table.remove(redoStack)
		if pAttached then
			exports[pAttachName]:setPositionOffset(element, unpack(nextState.position))
			exports[pAttachName]:setRotationOffset(element, unpack(nextState.position))
		else
			setElementPosition(element, unpack(nextState.position))
			setElementRotation(element, unpack(nextState.rotation))
		end
		setObjectScale(element, unpack(nextState.scale))
	end
end

function onResourceStart()
	bindKey(keyDragger, "down", stateControls)
	bindKey(keyUndo, "down", undo)
	bindKey(keyRedo, "down", redo)
end

addEventHandler("onClientResourceStart", resourceRoot, onResourceStart)

--[[

	Dependencies

]]

function getPositionFromElementOffset(element2, offX, offY, offZ)
	local m = getElementMatrix(element2)
	local m11, m12, m13 = m[1][1], m[1][2], m[1][3]
	local m21, m22, m23 = m[2][1], m[2][2], m[2][3]
	local m31, m32, m33 = m[3][1], m[3][2], m[3][3]
	local m41, m42, m43 = m[4][1], m[4][2], m[4][3]

	return offX * m11 + offY * m21 + offZ * m31 + m41,
		offX * m12 + offY * m22 + offZ * m32 + m42,
		offX * m13 + offY * m23 + offZ * m33 + m43
end

function isMouseInPosition(x, y, width, height)
	if not isCursorShowing() then
		return false
	end

	local sx2, sy2 = guiGetScreenSize()
	local cx, cy = getCursorPosition()
	cx, cy = cx * sx2, cy * sy2

	return cx >= x and cx <= x + width and cy >= y and cy <= y + height
end

function isEventHandlerAdded(sEventName, pElementAttachedTo, func)
	if type(sEventName) == 'string' and isElement(pElementAttachedTo) and type(func) == 'function' then
		local aAttachedFunctions = getEventHandlers(sEventName, pElementAttachedTo)
		if type(aAttachedFunctions) == 'table' and #aAttachedFunctions > 0 then
			for _, v in ipairs(aAttachedFunctions) do
				if v == func then
					return true
				end
			end
		end
	end
	return false
end

function getDistance(p1x, p1y, p2x, p2y)
	if p1x and p1y and p2x and p2y then
		return math.sqrt((p2x - p1x) * (p2x - p1x) + (p2y - p1y) * (p2y - p1y))
	else
		return false
	end
end

function areStatesEqual(state1, state2)
	return state1.element == state2.element
		and state1.position[1] == state2.position[1]
		and state1.position[2] == state2.position[2]
		and state1.position[3] == state2.position[3]
		and state1.rotation[1] == state2.rotation[1]
		and state1.rotation[2] == state2.rotation[2]
		and state1.rotation[3] == state2.rotation[3]
		and state1.scale[1] == state2.scale[1]
		and state1.scale[2] == state2.scale[2]
		and state1.scale[3] == state2.scale[3]
end
