--[[
	Made by Yeleha & waves

	This file is part of 3DEditor.

	3DEditor is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

	3DEditor is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along with 3DEditor. If not, see https://github.com/Derbosik/3DEditor/blob/main/LICENSE. 
]]

local editing, rotating, sizing = false, false, false
local x,y,z = false,false,false
local element = nil
local sx, sy = guiGetScreenSize()

local XYZlength = .5

local t = false
local oldX, oldY
setCursorAlpha(255)

function startEdit(elementik)
	element = elementik
	if not isElement(element) or getElementType(element) == "player" or getElementType(element) == "vehicle" or isElement(info) then
		return false
	end
	local pos = 100
	local dx, dy, dz = getElementPosition(element)
	local drx, dry, drz = getElementRotation(element)
	local dsx, dsy, dsz = getObjectScale(element)

	if not isEventHandlerAdded("onClientRender", root, drawControls) then
		editing = true
		addEventHandler("onClientRender", root, drawControls)
	end

	bMove = guiCreateStaticImage( 770/1920*sx, 900/1080*sy, 70/1920*sx, 70/1080*sy, "files/move.png", false )
	bRotate = guiCreateStaticImage( 850/1920*sx, 900/1080*sy, 70/1920*sx, 70/1080*sy, "files/rotate.png", false )
	bSize = guiCreateStaticImage( 930/1920*sx, 900/1080*sy, 70/1920*sx, 70/1080*sy, "files/size.png", false )
	bBin = guiCreateStaticImage( 1010/1920*sx, 900/1080*sy, 70/1920*sx, 70/1080*sy, "files/bin.png", false )
	bSave = guiCreateStaticImage( 1090/1920*sx, 900/1080*sy, 70/1920*sx, 70/1080*sy, "files/save.png", false )
	info = guiCreateLabel(700/1920*sx, 1000/1080*sy, 0/1920*sx, 0/1080*sy, "EDITOR \nHold down SHIFT to move faster and hold down ALT to move slower",false)
	--info = guiCreateLabel(700/1920*sx, 1000/1080*sy, 0/1920*sx, 0/1080*sy, "EDITOR \nPri držaní tlačítka SHIFT sa posúvanie zrýchli a pri držaní tlačítka ALT sa posúvanie spomalí",false)

	showCursor(true)

	addEventHandler("onClientGUIClick",root,function(button,state)
		if button=="left" and state=="up" then
			if source == bMove then
				guiSetAlpha(bRotate, 1)
				guiSetAlpha(bSize, 1)
				rotating = false
				editing = true
				sizing = false
			elseif source == bRotate then
				guiSetAlpha(bMove, 1)
				guiSetAlpha(bSize, 1)
				rotating = true
				editing = false
				sizing = false
			elseif source == bSize then
				guiSetAlpha(bRotate, 1)
				guiSetAlpha(bMove, 1)
				rotating = false
				editing = false
				sizing = true
			elseif source == bBin then
				if isElement(element) then
					setElementPosition(element, dx, dy, dz)
					setElementRotation(element, drx, dry, drz)
					setObjectScale(element, dsx, dsy, dsz)
                                        if not isElementLocal(element) then triggerServerEvent("editor:savedObject", localPlayer, sourceResource, element, dx, dy, dz, drx, dry, drz, dsx, dsy, dsz) end
					triggerEvent("editor:savedObject", localPlayer, sourceResource, element, dx, dy, dz, drx, dry, drz, dsx, dsy, dsz)
					closeMenu(false)
				end
			elseif source == bSave then
				if isElement(element) then
					local cx, cy, cz = getElementPosition(element)
					local rx, ry, rz = getElementRotation(element)
					local sx, sy, sz = getObjectScale(element)
					if not isElementLocal(element) then triggerServerEvent("editor:savedObject", localPlayer, sourceResource, element, cx, cy, cz, rx, ry, rz, sx, sy, sz) end
					triggerEvent("editor:savedObject", localPlayer, sourceResource, element, cx, cy, cz, rx, ry, rz, sx, sy, sz)
					closeMenu(false)
				end
			end
		end
	end)
end
addEvent("editor:startEdit", true)
addEventHandler("editor:startEdit", root, startEdit)

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
			guiSetAlpha(source, 0.65)
		end
	end
)

addEventHandler( "onClientMouseLeave", root, 
	function(aX, aY)
		if source == bMove or source == bRotate or source == bSize or source == bBin or source == bSave then
			if source == bMove and editing then return end
			if source == bRotate and rotating then return end
			if source == bSize and sizing then return end
			guiSetAlpha(source, 1)
		end
	end
)

function closeMenu()
	removeEventHandler("onClientRender",root,drawControls)
	removeEventHandler("onClientCursorMove",root,cursorMove)
	rotating = false
	editing = true
	sizing = false	
	element = nil
	meno = nil

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

			if getKeyState( "mouse1" ) == true then
				if (ix and iy and ix2 and iy2 and ix3 and iy3) then
					if isMouseInPosition(ix-10,iy-10,20,20) or isMouseInPosition(ix3-10,iy3-10,20,20) or isMouseInPosition(ix2-10,iy2-10,20,20) then
						if isMouseInPosition(ix-10,iy-10,20,20) then
							x = true
						elseif isMouseInPosition(ix2-10,iy2-10,20,20) then
							y = true
						elseif isMouseInPosition(ix3-10,iy3-10,20,20) then
							z = true
						end
						if not isEventHandlerAdded("onClientCursorMove", getRootElement( ), cursorMove) then
							addEventHandler( "onClientCursorMove", getRootElement( ), cursorMove)
						end
						setElementAlpha(localPlayer, 150)
						setCursorAlpha(0)
					end
				end
				absX,absY = absoluteX,absoluteY
			end
		elseif state == "up" then
			if x or y or z then
				setElementAlpha(localPlayer, 255)
				setCursorAlpha(255)
				setCursorPosition ( absX, absY )
				x = false
				y = false
				z = false
				removeEventHandler( "onClientCursorMove", getRootElement(), cursorMove)
			end
		end
	end
end
addEventHandler ( "onClientClick", getRootElement(), click )

function cursorMove(_,_,ax,ay)
	if getKeyState("mouse1")==true and isCursorShowing() and not t then
		t = true
		local cx, cy, cz = getElementPosition(element)
		local rx, ry, rz = getElementRotation(element)
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
				removeEventHandler( "onClientCursorMove", getRootElement(), cursorMove)
			end
		end

		local moveSpeed = 0.008
		local rotateSpeed = 5
		local sizeSpeed = 0.1
		if getKeyState("lalt")==true then
			moveSpeed = 0.003
			rotateSpeed = 2
		elseif getKeyState("lshift")==true then
			moveSpeed = 0.03
			rotateSpeed = 9
		end	

		if editing then
			if not (cx or cy or cz) then return end
			if x == true then
				if distance1>=distance2 then
					setElementPosition(element, cx + moveSpeed, cy, cz)
				else
					setElementPosition(element, cx - moveSpeed, cy, cz)
				end
				local ix, iy =  getScreenFromWorldPosition ( dx, dy, dz )
				setCursorPosition ( ix, iy )
			elseif y == true then
				if distance1>=distance2 then
					setElementPosition(element, cx, cy + moveSpeed, cz)
				else
					setElementPosition(element, cx, cy - moveSpeed, cz)
				end
				local ix, iy =  getScreenFromWorldPosition ( fx, fy, fz )
				setCursorPosition ( ix, iy )
			elseif z == true then
				if distance1>=distance2 then
					setElementPosition(element,cx, cy, cz + moveSpeed)
				else
					setElementPosition(element, cx, cy, cz - moveSpeed)
				end
				local ix, iy =  getScreenFromWorldPosition ( ux, uy, uz )
				setCursorPosition ( ix, iy )
			end
		elseif rotating then
			if x == true then
				if distance1>=distance2 then
					setElementRotation(element, rx + rotateSpeed, ry, rz)
				else
					setElementRotation(element, rx - rotateSpeed, ry, rz)
				end
				local ix, iy =  getScreenFromWorldPosition ( dx, dy, dz )
				setCursorPosition ( ix, iy )
			elseif y == true then
				if distance1>=distance2 then
					setElementRotation(element, rx, ry + rotateSpeed, rz)
				else
					setElementRotation(element, rx, ry - rotateSpeed, rz)
				end
				local ix, iy =  getScreenFromWorldPosition ( fx, fy, fz )
				setCursorPosition ( ix, iy )
			elseif z == true then
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
			if x == true then
				if distance1>=distance2 then
					setObjectScale(element, s1 + sizeSpeed, s2, s3)
				else
					setObjectScale(element, s1 - sizeSpeed, s2, s3)
				end
				local ix, iy =  getScreenFromWorldPosition ( dx, dy, dz )
				setCursorPosition ( ix, iy )
			elseif y == true then
				if distance1>=distance2 then
					setObjectScale(element, s1, s2 + sizeSpeed, s3)
				else
					setObjectScale(element, s1, s2 - sizeSpeed, s3)
				end
				local ix, iy =  getScreenFromWorldPosition ( fx, fy, fz )
				setCursorPosition ( ix, iy )
			elseif z == true then
				if distance1>=distance2 then
					setObjectScale(element, s1, s2, s3 + sizeSpeed)
				else
					setObjectScale(element, s1, s2, s3 - sizeSpeed)
				end
				local ix, iy =  getScreenFromWorldPosition ( ux, uy, uz )
				setCursorPosition ( ix, iy )
			end			
		end
		setTimer(function()
			t = false
		end,50,1)
	elseif (not isCursorShowing()) then
		setCursorAlpha(255)
	end
	oldX, oldY = ax, ay
end

--[[

	Dependancies

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
