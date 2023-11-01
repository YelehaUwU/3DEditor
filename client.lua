--[[
	Made by Yeleha (Derbosik)

	This file is part of 3DEditor.

	3DEditor is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

	3DEditor is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along with 3DEditor. If not, see https://github.com/Derbosik/3DEditor/blob/main/LICENSE. 
]]

-- You can modify these safely.
local keyDragger = "mouse1"
local keyUndo = "q"
local keyRedo = "e"

-- Don't touch these if you don't know what you're doing.
local sx, sy = guiGetScreenSize()
local XYZlength = .5
local sourceResElement

local undoStack = {}
local redoStack = {}
local lastState
local pAttached

local disabledMoving
local disabledRotating
local disabledScaling


function startEdit(elementik, disableMoving, disableRotate, disableScale, sourceRes)
	element = elementik
	if not isElement(element) or getElementType(element) == "player" or getElementType(element) == "vehicle" or isElement(info) then
		return false
	end
	sourceResElement = nil

	if not sourceRes then
		disabledMoving = disableMoving
		disabledRotating = disableRotate
		disabledScaling = disableScale
		sourceResElement = sourceResource
	else 
		disabledMoving = disableMoving
		disabledRotating = disableRotate
		disabledScaling = disableScale
		sourceResElement = sourceRes
	end

	local pos = 100
	local dx, dy, dz = getElementPosition(element)
	local drx, dry, drz = getElementRotation(element)
	local dsx, dsy, dsz = getObjectScale(element)

	local px, py, pz
	local prx, pry, prz

	if getResourceFromName(pAttachName) and getResourceState(getResourceFromName(pAttachName)) == "running" and exports[pAttachName]:isAttached(element) then
		pAttached = true
		local details = exports[pAttachName]:getDetails(element)
		px = details[4]
		py = details[5]
		pz = details[6]
		prx = details[7]
		pry = details[8]
		prz = details[9]
	end

	if not isEventHandlerAdded("onClientRender", root, drawControls) then
		if not disabledMoving then editing = true
		elseif not disabledRotating then rotating = true
		elseif not disabledScaling then sizing = true
		else return false end
		addEventHandler("onClientRender", root, drawControls)
	end

	bMove = guiCreateStaticImage( 770/1920*sx, 900/1080*sy, 70/1920*sx, 70/1080*sy, "files/move.png", false )
	guiSetAlpha(bMove, disabledMoving and 0.25 or 1)
	bRotate = guiCreateStaticImage( 850/1920*sx, 900/1080*sy, 70/1920*sx, 70/1080*sy, "files/rotate.png", false )
	guiSetAlpha(bRotate, disabledRotating and 0.25 or 1)
	bSize = guiCreateStaticImage( 930/1920*sx, 900/1080*sy, 70/1920*sx, 70/1080*sy, "files/size.png", false )
	guiSetAlpha(bSize, disabledScaling and 0.25 or 1)
	bBin = guiCreateStaticImage( 1010/1920*sx, 900/1080*sy, 70/1920*sx, 70/1080*sy, "files/bin.png", false )
	bSave = guiCreateStaticImage( 1090/1920*sx, 900/1080*sy, 70/1920*sx, 70/1080*sy, "files/save.png", false )
	info = guiCreateLabel(700/1920*sx, 1000/1080*sy, 0/1920*sx, 0/1080*sy, "EDITOR \nHold down SHIFT to move faster and hold down ALT to move slower",false)

	showCursor(true)

	addEventHandler("onClientGUIClick",root,function(button,state)
		if button=="left" and state=="up" then
			if source == bMove and not disabledMoving then
				if not disabledRotating then guiSetAlpha(bRotate, 1) end
				if not disabledScaling then guiSetAlpha(bSize, 1) end
				rotating = false
				editing = true
				sizing = false
			elseif source == bRotate and not disabledRotating then
				if not disabledMoving then guiSetAlpha(bMove, 1) end
				if not disabledScaling then guiSetAlpha(bSize, 1) end
				rotating = true
				editing = false
				sizing = false
			elseif source == bSize and not disabledScaling then
				if not disabledRotating then guiSetAlpha(bRotate, 1) end
				if not disabledMoving then guiSetAlpha(bMove, 1) end
				rotating = false
				editing = false
				sizing = true
			elseif source == bBin then
				if isElement(element) then
					setObjectScale(element, dsx, dsy, dsz)
					if pAttached then
						exports[pAttachName]:setPositionOffset(element, px, py, pz)
						exports[pAttachName]:setRotationOffset(element, prx, pry, prz)
						local details = exports[pAttachName]:getDetails(element)
						if not isElementLocal(element) then triggerServerEvent("3DEditor:savedAttachedObject", resourceRoot, sourceResElement, element, px, py, pz, prx, pry, prz, dsx, dsy, dsz) end
						triggerEvent("3DEditor:savedAttachedObject", localPlayer, sourceResElement, element, px, py, pz, prx, pry, prz, dsx, dsy, dsz)
					else
						setElementPosition(element, dx, dy, dz)
						setElementRotation(element, drx, dry, drz)
						if not isElementLocal(element) then triggerServerEvent("3DEditor:savedObject", resourceRoot, sourceResElement, element, dx, dy, dz, drx, dry, drz, dsx, dsy, dsz) end
						triggerEvent("3DEditor:savedObject", localPlayer, sourceResElement, element, dx, dy, dz, drx, dry, drz, dsx, dsy, dsz)
					end
					closeMenu()
				end
			elseif source == bSave then
				if isElement(element) then
					local sx, sy, sz = getObjectScale(element)
					if pAttached then
						local details = exports[pAttachName]:getDetails(element)
						if not isElementLocal(element) then triggerServerEvent("3DEditor:savedAttachedObject", resourceRoot, sourceResElement, element, details[4], details[5], details[6], details[7], details[8], details[9], sx, sy, sz) end
						triggerEvent("3DEditor:savedAttachedObject", localPlayer, sourceResElement, element, details[4], details[5], details[6], details[7], details[8], details[9], sx, sy, sz)
					else
						local cx, cy, cz = getElementPosition(element)
						local rx, ry, rz = getElementRotation(element)
						if not isElementLocal(element) then triggerServerEvent("3DEditor:savedObject", resourceRoot, sourceResElement, element, cx, cy, cz, rx, ry, rz, sx, sy, sz) end
						triggerEvent("3DEditor:savedObject", localPlayer, sourceResElement, element, cx, cy, cz, rx, ry, rz, sx, sy, sz)
					end
					closeMenu()
				end
			end
		end
	end)
end
addEvent("3DEditor:startEdit", true)
addEventHandler("3DEditor:startEdit", root, startEdit)

function drawControls()
	if (isElement(element)) then
		dx,dy,dz = getPositionFromElementOffset( element, XYZlength, 0, 0)
		fx,fy,fz = getPositionFromElementOffset( element, 0, XYZlength, 0)
		ux,uy,uz = getPositionFromElementOffset( element, 0, 0, XYZlength)
		px,py,pz = getElementPosition( element )

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

		mX, mY =  getScreenFromWorldPosition ( px, py, pz )
		if (mX and mY) then

			ix, iy =  getScreenFromWorldPosition ( dx, dy, dz, 1 )
			ix2, iy2 =  getScreenFromWorldPosition ( fx, fy, fz, 1 )
			ix3, iy3 =  getScreenFromWorldPosition ( ux, uy, uz, 1 )

			local red = tocolor( 255, 0, 0, 230 )
			local green = tocolor( 0, 255, 0, 230 )
			local blue = tocolor( 0, 0, 255, 230 )

			if (ix and iy and ix2 and iy2 and ix3 and iy3) then

				if isMouseInPosition(ix-10,iy-10,20,20) or x then
					red = tocolor( 150, 0, 0, 255 )
				elseif isMouseInPosition(ix2-10,iy2-10,20,20) or y then
					green = tocolor( 0, 150, 0, 255 )
				elseif isMouseInPosition(ix3-10,iy3-10,20,20) or z then
					blue = tocolor( 0, 0, 150, 255 )
				end

				dxDrawLine ( ix, iy, mX, mY, red, 2, false)
				dxDrawImage ( ix-10, iy-10, 20, 20, 'files/'..xImage..'.png', 0, 0, 0, tocolor( 255, 255, 255, 230 ), false )

				dxDrawLine ( ix2, iy2, mX, mY, green, 2, false)
				dxDrawImage ( ix2-10, iy2-10, 20, 20, 'files/'..yImage..'.png', 0, 0, 0, tocolor( 255, 255, 255, 230 ), false )

				dxDrawLine ( ix3, iy3, mX, mY, blue, 2, false)
				dxDrawImage ( ix3-10, iy3-10, 20, 20, 'files/'..zImage..'.png', 0, 0, 0, tocolor( 255, 255, 255, 230 ), false )
			end
		end
	else
		closeMenu(true)
	end
end

addEventHandler( "onClientMouseEnter", root, 
	function(aX, aY)
		if source == bMove or source == bRotate or source == bSize or source == bBin or source == bSave then
			if source == bMove and editing then return end
			if source == bRotate and rotating then return end
			if source == bSize and sizing then return end
			guiSetAlpha(source, 0.5)
		end
	end
)

addEventHandler( "onClientMouseLeave", root, 
	function(aX, aY)
		if source == bMove or source == bRotate or source == bSize or source == bBin or source == bSave then
			if source == bMove and editing then return end
			if source == bRotate and rotating then return end
			if source == bSize and sizing then return end
			if source == bMove and disabledMoving then guiSetAlpha(source, 0.25) return end
			if source == bRotate and disabledRotating then guiSetAlpha(source, 0.25) return end
			if source == bSize and disabledScaling then guiSetAlpha(source, 0.25) return end
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

    rotating = false
    editing = true
    sizing = false
    element = nil
	
	disabledMoving = false
	disabledRotating = false
	disabledScaling = false

    destroyElement(bSize)
    destroyElement(bRotate)
    destroyElement(bMove)
    destroyElement(bBin)
    destroyElement(bSave)
    destroyElement(info)
    showCursor(false)
end

function click( button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement )
	oldX, oldY = nil, nil
	if isElement(element) then
		if state == "down" then
			local px,py,pz = getElementPosition( element )
			if getKeyState( keyDragger ) then
				if (ix and iy and ix2 and iy2 and ix3 and iy3) then
					if isMouseInPosition(ix-10,iy-10,20,20) or isMouseInPosition(ix3-10,iy3-10,20,20) or isMouseInPosition(ix2-10,iy2-10,20,20) then
						if isMouseInPosition(ix-10,iy-10,20,20) then
							x = true
						elseif isMouseInPosition(ix2-10,iy2-10,20,20) then
							y = true
						elseif isMouseInPosition(ix3-10,iy3-10,20,20) then
							z = true
						end
						if not isEventHandlerAdded("onClientCursorMove", root, cursorMove) then
							addEventHandler( "onClientCursorMove", root, cursorMove)
						end
						setElementAlpha(localPlayer, 150)
						setCursorAlpha(0)
					end
				end
				absX,absY = absoluteX,absoluteY
			elseif getKeyState("mouse2") then
				showCursor(false)
			end
		elseif state == "up" then
			if x or y or z then
				setElementAlpha(localPlayer, 255)
				setCursorAlpha(255)
				setCursorPosition ( absX, absY )
				x = false
				y = false
				z = false
				removeEventHandler( "onClientCursorMove", root, cursorMove)
			end
		end
	end
end
addEventHandler ( "onClientClick", root, click )

function cursorRestore(button, press)
	if isElement(element) and button == "mouse2" and not press then
		showCursor(true)
	end
end
addEventHandler("onClientKey", root, cursorRestore)

function cursorMove(_,_,ax,ay)
	if getKeyState(keyDragger) and isCursorShowing() and not t then
		t = true
		local distance1 = getDistance(mX, mY, ax, ay)
		local distance2 = getDistance(mX, mY, oldX or absX, oldY or absY)

		if not (distance1 or distance2) then
			if x or y or z then
				setElementAlpha(localPlayer, 255)
				setCursorAlpha(255)
				setCursorPosition ( absX, absY )
				x = false
				y = false
				z = false
				removeEventHandler( "onClientCursorMove", root, cursorMove)
			end
		end

		local moveSpeed = 0.008
		local rotateSpeed = 5
		local sizeSpeed = 0.1
		if getKeyState("lalt") then
			moveSpeed = 0.003
			rotateSpeed = 2
		elseif getKeyState("lshift") then
			moveSpeed = 0.03
			rotateSpeed = 9
		end	

		if pAttached and exports[pAttachName]:isAttached(element) then
			local details = exports[pAttachName]:getDetails(element)
			local cx = details[4]
			local cy = details[5]
			local cz = details[6]
			local rx = details[7]
			local ry = details[8]
			local rz = details[9]
			if editing then
				if not (cx or cy or cz) then return end
				if x then
					if distance1>=distance2 then
						exports[pAttachName]:setPositionOffset(element, cx + moveSpeed, cy, cz)
					else
						exports[pAttachName]:setPositionOffset(element, cx - moveSpeed, cy, cz)
					end
					local ix, iy =  getScreenFromWorldPosition ( dx, dy, dz )
					setCursorPosition ( ix, iy )
				elseif y then
					if distance1>=distance2 then
						exports[pAttachName]:setPositionOffset(element, cx, cy + moveSpeed, cz)
					else
						exports[pAttachName]:setPositionOffset(element, cx, cy - moveSpeed, cz)
					end
					local ix, iy =  getScreenFromWorldPosition ( fx, fy, fz )
					setCursorPosition ( ix, iy )
				elseif z then
					if distance1>=distance2 then
						exports[pAttachName]:setPositionOffset(element,cx, cy, cz + moveSpeed)
					else
						exports[pAttachName]:setPositionOffset(element, cx, cy, cz - moveSpeed)
					end
					local ix, iy =  getScreenFromWorldPosition ( ux, uy, uz )
					setCursorPosition ( ix, iy )
				end
			elseif rotating then
				if x then
					if distance1>=distance2 then
						exports[pAttachName]:setRotationOffset(element, rx + rotateSpeed, ry, rz)
					else
						exports[pAttachName]:setRotationOffset(element, rx - rotateSpeed, ry, rz)
					end
					local ix, iy =  getScreenFromWorldPosition ( dx, dy, dz )
					setCursorPosition ( ix, iy )
				elseif y then
					if distance1>=distance2 then
						exports[pAttachName]:setRotationOffset(element, rx, ry + rotateSpeed, rz)
					else
						exports[pAttachName]:setRotationOffset(element, rx, ry - rotateSpeed, rz)
					end
					local ix, iy =  getScreenFromWorldPosition ( fx, fy, fz )
					setCursorPosition ( ix, iy )
				elseif z then
					if distance1>=distance2 then
						exports[pAttachName]:setRotationOffset(element, rx, ry, rz + rotateSpeed)
					else
						exports[pAttachName]:setRotationOffset(element, rx, ry, rz - rotateSpeed)
					end
					local ix, iy =  getScreenFromWorldPosition ( ux, uy, uz )
					setCursorPosition ( ix, iy )
				end
			elseif sizing then
				local s1, s2, s3 = getObjectScale( element )
				if x then
					if distance1>=distance2 then
						setObjectScale(element, s1 + sizeSpeed, s2, s3)
					else
						setObjectScale(element, s1 - sizeSpeed, s2, s3)
					end
					local ix, iy =  getScreenFromWorldPosition ( dx, dy, dz )
					setCursorPosition ( ix, iy )
				elseif y then
					if distance1>=distance2 then
						setObjectScale(element, s1, s2 + sizeSpeed, s3)
					else
						setObjectScale(element, s1, s2 - sizeSpeed, s3)
					end
					local ix, iy =  getScreenFromWorldPosition ( fx, fy, fz )
					setCursorPosition ( ix, iy )
				elseif z then
					if distance1>=distance2 then
						setObjectScale(element, s1, s2, s3 + sizeSpeed)
					else
						setObjectScale(element, s1, s2, s3 - sizeSpeed)
					end
					local ix, iy =  getScreenFromWorldPosition ( ux, uy, uz )
					setCursorPosition ( ix, iy )
				end
			end
		else
			local cx, cy, cz = getElementPosition(element)
			local rx, ry, rz = getElementRotation(element)
			if editing then
				if not (cx or cy or cz) then return end
				if x then
					if distance1>=distance2 then
						setElementPosition(element, cx + moveSpeed, cy, cz)
					else
						setElementPosition(element, cx - moveSpeed, cy, cz)
					end
					local ix, iy =  getScreenFromWorldPosition ( dx, dy, dz )
					setCursorPosition ( ix, iy )
				elseif y then
					if distance1>=distance2 then
						setElementPosition(element, cx, cy + moveSpeed, cz)
					else
						setElementPosition(element, cx, cy - moveSpeed, cz)
					end
					local ix, iy =  getScreenFromWorldPosition ( fx, fy, fz )
					setCursorPosition ( ix, iy )
				elseif z then
					if distance1>=distance2 then
						setElementPosition(element,cx, cy, cz + moveSpeed)
					else
						setElementPosition(element, cx, cy, cz - moveSpeed)
					end
					local ix, iy =  getScreenFromWorldPosition ( ux, uy, uz )
					setCursorPosition ( ix, iy )
				end
			elseif rotating then
				if x then
					if distance1>=distance2 then
						setElementRotation(element, rx + rotateSpeed, ry, rz)
					else
						setElementRotation(element, rx - rotateSpeed, ry, rz)
					end
					local ix, iy =  getScreenFromWorldPosition ( dx, dy, dz )
					setCursorPosition ( ix, iy )
				elseif y then
					if distance1>=distance2 then
						setElementRotation(element, rx, ry + rotateSpeed, rz)
					else
						setElementRotation(element, rx, ry - rotateSpeed, rz)
					end
					local ix, iy =  getScreenFromWorldPosition ( fx, fy, fz )
					setCursorPosition ( ix, iy )
				elseif z then
					if distance1>=distance2 then
						setElementRotation(element, rx, ry, rz + rotateSpeed)
					else
						setElementRotation(element, rx, ry, rz - rotateSpeed)
					end
					local ix, iy =  getScreenFromWorldPosition ( ux, uy, uz )
					setCursorPosition ( ix, iy )
				end
			elseif sizing then
				local s1, s2, s3 = getObjectScale( element )
				if x then
					if distance1>=distance2 then
						setObjectScale(element, s1 + sizeSpeed, s2, s3)
					else
						setObjectScale(element, s1 - sizeSpeed, s2, s3)
					end
					local ix, iy =  getScreenFromWorldPosition ( dx, dy, dz )
					setCursorPosition ( ix, iy )
				elseif y then
					if distance1>=distance2 then
						setObjectScale(element, s1, s2 + sizeSpeed, s3)
					else
						setObjectScale(element, s1, s2 - sizeSpeed, s3)
					end
					local ix, iy =  getScreenFromWorldPosition ( fx, fy, fz )
					setCursorPosition ( ix, iy )
				elseif z then
					if distance1>=distance2 then
						setObjectScale(element, s1, s2, s3 + sizeSpeed)
					else
						setObjectScale(element, s1, s2, s3 - sizeSpeed)
					end
					local ix, iy =  getScreenFromWorldPosition ( ux, uy, uz )
					setCursorPosition ( ix, iy )
				end
			end
		end
		setTimer(function()
			t = false
		end, 25, 1)
	elseif not isCursorShowing() then
		setCursorAlpha(255)
	end
	oldX, oldY = ax, ay
end

function stateControls(key, state)
	if element then
		local currentState = {
			position = {getElementPosition(element)},
			rotation = {getElementRotation(element)},
			scale = {getObjectScale(element)}
		}
		if pAttached then
			local details = exports[pAttachName]:getDetails(element)
			currentState = {
				position = {details[4], details[5], details[6]},
				rotation = {details[7], details[8], details[9]},
				scale = {getObjectScale(element)}
			}
		end
		if #undoStack == 0 or not areStatesEqual(currentState, undoStack[#undoStack]) then
			table.insert(undoStack, currentState)
		end
	end
end
bindKey(keyDragger, "down", stateControls)

function undo()
    if element and #undoStack > 0 then
        local currentState = {
            position = {getElementPosition(element)},
            rotation = {getElementRotation(element)},
            scale = {getObjectScale(element)}
        }
		if pAttached then
			local details = exports[pAttachName]:getDetails(element)
			currentState = {
				position = {details[4], details[5], details[6]},
				rotation = {details[7], details[8], details[9]},
				scale = {getObjectScale(element)}
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
bindKey(keyUndo, "down", undo)

function redo()
    if element and #redoStack > 0 then
        local currentState = {
            position = {getElementPosition(element)},
            rotation = {getElementRotation(element)},
            scale = {getObjectScale(element)}
        }
		if pAttached then
			local details = exports[pAttachName]:getDetails(element)
			currentState = {
				position = {details[4], details[5], details[6]},
				rotation = {details[7], details[8], details[9]},
				scale = {getObjectScale(element)}
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
bindKey(keyRedo, "down", redo)

--[[

	Dependencies

]]

function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix(element)
    return offX*m[1][1]+offY*m[2][1]+offZ*m[3][1]+m[4][1],offX*m[1][2]+offY*m[2][2]+offZ*m[3][2]+m[4][2],offX*m[1][3]+offY*m[2][3]+offZ*m[3][3]+m[4][3]
end

function isMouseInPosition (x, y, width, height)
	if not isCursorShowing() then
		return false
	end
	local sx, sy = guiGetScreenSize()
	local cx, cy = getCursorPosition()
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end

function isEventHandlerAdded(sEventName, pElementAttachedTo, func)
    if type( sEventName ) == 'string' and isElement( pElementAttachedTo ) and type( func ) == 'function' then
        local aAttachedFunctions = getEventHandlers( sEventName, pElementAttachedTo )
        if type( aAttachedFunctions ) == 'table' and #aAttachedFunctions > 0 then
            for i, v in ipairs( aAttachedFunctions ) do
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