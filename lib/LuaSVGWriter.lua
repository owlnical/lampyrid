local SVGWriter = {}



local LineBuilder = {}
LineBuilder.__index = LineBuilder

function LineBuilder:new(indentAmount, newlineText)
   local ret = {
      indentAmount = indentAmount or 2,
      newlineText = newlineText or "\n",
      indentLevel = 0,
      indentText = "",
      text = ""
   }
   setmetatable(ret, self)
   return ret
end


function LineBuilder:__createIndentText()
   local spaceCount
   if self.indentLevel <= 0 then
      spaceCount = 0
   else
      spaceCount = self.indentLevel * self.indentAmount
   end
   self.indentText = string.rep(" ", spaceCount)
end

function LineBuilder:indent()
   self.indentLevel = self.indentLevel + 1
   self:__createIndentText()
end

function LineBuilder:unindent()
   if self.indentLevel <= 1 then
      self.indentLevel = 0
   else
      self.indentLevel = self.indentLevel - 1
   end
   self:__createIndentText()
end

function LineBuilder:add(line)
   line = line or ""
   local realLine = self.indentText .. line .. self.newlineText
   self.text = self.text .. realLine
end

function LineBuilder:get()
   return self.text
end

function assertNotNilTable(theTable)
   assert(theTable, "SVG Object is nil")
   assert(type(theTable) == "table", "SVG Object parameter is not a table")
end

local function assertValidRef(svgObject)
   assertNotNilTable(svgObject)
   assert(svgObject.__canBeRef,
          "SVG Object parameter is not a valid definition" ) 
end

local function assertDrawableNode(svgObject)
   assertNotNilTable(svgObject)
   assert(svgObject.__canBeDrawn,
          "SVG Object parameter is not a valid definition" ) 
end

local function generateAttributeText(attributeTable, order, cssFormat)
   cssFormat = cssFormat or false
   function createPairString(k, value, cssFormat)
      local convertedKey = string.gsub(k, "_", "-")
      local stringValue
      if type(value) == "table" then
         assert(value.idText, "Expeted table value to have and ID")
         stringValue = "url(#" .. tostring(value.idText) .. ")"
      else
         stringValue = tostring(value)
      end
      if cssFormat then
         return convertedKey .. ":" .. stringValue .. ";"
      else
         return convertedKey .. "=\"" .. stringValue .. "\""
      end
   end

   if attributeTable == nil then return "" end 
   
   assert(type(attributeTable) == "table", "attributeTable parameter is not a table")

   local str = ""
   local preSpace = ""
   local orderHasValue = nil
   
   if order then
      orderHasValue = {}
      for i, k in ipairs(order) do
         local k2 = string.gsub(k, "-", "_")
         orderHasValue[k] = true
         orderHasValue[k2] = true
         local value = attributeTable[k] or attributeTable[k2]
         if value ~= nil then
            str = str .. preSpace .. createPairString(k, value, cssFormat)
            if not cssFormat then preSpace = " " end
         end
      end
   end
   for k, v in pairs(attributeTable) do
      -- orderHasValue[k] will be true if order contains k otherwise it will
      -- be nil
      if order == nil or not orderHasValue[k] then
         str = str .. preSpace .. createPairString(k, v, cssFormat)
         if not cssFormat then preSpace = " " end
      end
   end
   return str
end

local function generateTransformText(transforms)
   if transforms == nil then return "" end
   assert(type(transforms) == "table", "Parameter transforms expected to be a table")
   local text = ""
   local preSpace = ""
   for i, v in ipairs(transforms) do
      text = text .. preSpace .. v:generateText()
      preSpace = " "
   end
   return text
end

local function generatePointsText(points)
   if points == nil then
      return ""
   end
   assert(type(points) == "table", "Parameter points is expected to be a table")
   
   local preSpace = ""
   local text = ""
   for i, v in ipairs(points) do
      text = string.format("%s%s%s,%s", text, preSpace, tostring(v.x), tostring(v.y))
      preSpace = " "
   end
   return text
end

local function generateAttributeTextMethod(self, useCSSStyleTag)
   useCSSStyleTag = useCSSStyleTag or false
   local text = ""
   
   if self.idText == nil and 
      self.id ~= nil then
      self.idText = self.id
   end
   
   if self.idText then
      text = text .. " id=\"" .. self.idText .. "\""
   end
   if self.transforms and
      next(self.transforms) ~= nil then
      text = text .. 
             " transform=\"" .. generateTransformText(self.transforms) .. "\""
   end
   
   if self.typeAttributes and 
      next(self.typeAttributes) ~= nil then

      text = text .. " " .. 
             generateAttributeText(self.typeAttributes,  self.__attributeTypeOrder)
   end
   if self.style and
      next(self.style.styleAttributes) ~= nil then
      if useCSSStyleTag then
         text = text .. 
                " " .. 
                generateAttributeText(self.style.styleAttributes, self.__attributeStyleOrder)
      else
         text = text .. 
                " style=\"" .. 
                generateAttributeText(self.style.styleAttributes, self.__attributeStyleOrder, true) ..
                "\""
      end
   end
   return text
end

local function stringOrEmpty(formatStr, value)
   if value == nil then
      return ""
   end
   return string.format(formatStr, value)
end

local transformClass = {}
function transformClass:matrix(a, b, c, d, e, f)
   assert(a ~= nil, "Expected value for a")
   assert(b ~= nil, "Expected value for b")
   assert(c ~= nil, "Expected value for c")
   assert(d ~= nil, "Expected value for d")
   assert(e ~= nil, "Expected value for e")
   assert(f ~= nil, "Expected value for f")
   local tranform = {
      a = a or 0,
      b = b or 0,
      c = c or 0,
      d = d or 0,
      e = e or 0,
      f = f or 0,
   }
   function tranform:generateText()
      return string.format("matrix(%s,%s,%s,%s,%s,%s)", 
                           tostring(self.a), 
                           tostring(self.b), 
                           tostring(self.c), 
                           tostring(self.d), 
                           tostring(self.e), 
                           tostring(self.f))
   end
   
   table.insert(self.transforms, tranform)
   return self
end

function transformClass:translate(x, y)
   assert(x ~= nil, "Expected valid x value")
   local tranform = {
      x = x,
      y = y
   }
   function tranform:generateText()
      return string.format("translate(%s%s)", 
                           tostring(self.x), 
                           stringOrEmpty(",%s",self.y))
   end
   
   table.insert(self.transforms, tranform)
   return self
end

function transformClass:scale(x, y)
   assert(x ~= nil, "Scale Expects at least one parameter")
   local tranform = {
      x = x or 0,
      y = y
   }
   function tranform:generateText()
      return string.format("scale(%s%s)", 
                           tostring(self.x), 
                           stringOrEmpty(",%s",self.y))
   end
   
   table.insert(self.transforms, tranform)
   return self
end

function transformClass:rotate(angle, x, y)
   assert(angle ~= nil, "Expected angle parameter to be not nil")
   local tranform = {
      angle = angle,
      x = x,
      y = y
   }
   function tranform:generateText()
      return string.format("rotate(%s%s%s)", 
                           tostring(self.angle), 
                           stringOrEmpty(",%s", self.x), 
                           stringOrEmpty(",%s", self.y))
   end
   
   table.insert(self.transforms, tranform)
   return self
end

function transformClass:skewX(value)
   assert(value ~= nil, "Expected value parameter to be not nil")
   local tranform = {
      value = value
   }
   function tranform:generateText()
      return string.format("skewX(%s)", tostring(self.value))
   end
   
   table.insert(self.transforms, tranform)
   return self
end

function transformClass:skewY(value)
   assert(value ~= nil, "Expected value parameter to be not nil")
   local tranform = {
      value = value
   }
   function tranform:generateText()
      return string.format("skewY(%s)", tostring(self.value))
   end
   
   table.insert(self.transforms, tranform)
   return self
end

local function copyInto(dest, src)
   if src then
      for k, v in pairs(src) do
         dest[k] = v;
      end
   end
   return dest
end

local function mergeIntoNew(...)
   local new = {}
   for i, v in ipairs({...}) do
      for i2, v2 in ipairs(v) do
         table.insert(new, v2)
      end
   end
   return new
end


--- Color Functions
SVGWriter.Color = {}

local function saturate(value, minimum, maximum)
   minimum = minimum or 0
   maximum = maximum or 1
   if value < minimum then
      return minimum
   elseif value > maximum then
      return maximum
   else
      return value
   end
end
local function ratioToByte(ratio)
   return math.floor((ratio * 255) + 0.5)
end

function SVGWriter.Color.Grey(value)
   local intValue = ratioToByte(saturate(value))
   return string.format("#%02x%02x%02x", intValue, intValue, intValue)
end

function SVGWriter.Color.RGB(red, green, blue)
   local intRed   = ratioToByte(saturate(red))
   local intGreen = ratioToByte(saturate(green))
   local intBlue  = ratioToByte(saturate(blue))
   return string.format("#%02x%02x%02x", intRed, intGreen, intBlue)
end


function SVGWriter.Color.HSL(hue, saturation, lightness)
   lightness  = saturate(lightness or 0)
   saturation = saturate(saturation or 0)
   hue        = saturate(hue or 0)
   local chroma = (1 - math.abs((2 * lightness) - 1)) * saturation
   local sextant = math.floor(hue * 6)
   local x = chroma * (1 - math.abs(math.fmod(hue * 6, 2) - 1))
   local red
   local green
   local blue
   if sextant == 0 then
      red   = chroma
      green = x
      blue  = 0
   elseif sextant == 1 then
      red   = x
      green = chroma
      blue  = 0
   elseif sextant == 2 then
      red   = 0
      green = chroma
      blue  = x
   elseif sextant == 3 then
      red   = 0
      green = x
      blue  = chroma
   elseif sextant == 4 then
      red   = x
      green = 0
      blue  = chroma
   else
      red   = chroma
      green = 0
      blue  = x
   end

   local m = lightness - chroma / 2.0
   --print("chroma", chroma, "sextant", sextant, "x", x, "m", m)
   
   local intRed   = ratioToByte(red + m)
   local intGreen = ratioToByte(green + m)
   local intBlue  = ratioToByte(blue + m)
   return string.format("#%02x%02x%02x", intRed, intGreen, intBlue)
end

function assertSetAdd(set, item)
   for i, v in ipairs(set) do
      assert(v ~= item, "Attempted to add duplicate item to set")
   end
end

local refrenceClass = {}

function refrenceClass:setID(id)
   self.id = id
   return self
end

refrenceClass.__canBeRef = true

local function addSVGObjectToDefinedSet(definedSet, object)
   if definedSet ~= nil then 
      definedSet[object] = true 
   end
end

local function addSVGObjectToRefrenceSet(refrenceSet, object)
   if refrenceSet ~= nil and 
      refrenceSet.set[object] == nil then
      table.insert(refrenceSet.order, object)
      refrenceSet.set[object] = true
   end
end

local function scanAttributesForRefs(attributes, refrenceSet, definedSet)
   if attributes ~= nil then
      for k, v in pairs(attributes) do
         if type(v) == "table" then
            assertValidRef(v)
            addSVGObjectToRefrenceSet(refrenceSet, v)
            v:__scanForRefs(refrenceSet, nil)
         end
      end
   end
end

SVGWriter.Style = {}
SVGWriter.Style.__index = SVGWriter.Style
function SVGWriter.Style:new(stroke, stroke_width, fill, fill_opacity, stroke_opacity)
   local style = {}
   setmetatable(style, self)
   
   if type(stroke) == "table" then
      style.styleAttributes = copyInto({}, stroke)
   else
      style.styleAttributes = {
         stroke         = stroke,
         stroke_width   = stroke_width,
         fill           = fill,
         fill_opacity   = fill_opacity,
         stroke_opacity = stroke_opacity
      }
   end
   return style
end

function SVGWriter.Style:copy()
   local newStyle = {
      styleAttributes = copyInto({}, self.styleAttributes)
   }
   setmetatable(newStyle, SVGWriter.Style)
   return newStyle
end

function SVGWriter.Style:add(style, value)
   if type(style) == "string" then
      assert(value ~= nil, "Expected value if style is a string")
      self.styleAttributes[style] = value
   else
      assert(type(style) == "table", "Expected style to be a table in this context")
      if getmetatable(style) == SVGWriter.Style then
         copyInto(self.styleAttributes, style.styleAttributes)
      else
         copyInto(self.styleAttributes, style)
      end
   end
   return self
end

function SVGWriter.Style:apply(svgObject)
   assert(svgObject.__canBeStyled, "svgObject cannot be styled")
   svgObject.style = self:copy()
   return self
end

function SVGWriter.Style:setFill(fill, opacity)
   self.styleAttributes.fill = fill
   if opacity ~= nil then
      self.styleAttributes.fill_opacity = opacity
   end
   return self
end


function SVGWriter.Style:setStroke(stroke, width, opacity)
   self.styleAttributes.stroke = stroke
   if width ~= nil then
      self.styleAttributes.stroke_width = width
   end
   if opacity ~= nil then
      self.styleAttributes.stroke_opacity = opacity
   end
   return self
end

function SVGWriter.Style:setOpacity(opacity)
   self.styleAttributes.opacity = opacity
   return self
end

function SVGWriter.Style:setStrokeWidth(width)
   self.styleAttributes.stroke_width = width
   return self
end

function SVGWriter.Style:noStroke()
   self.styleAttributes.stroke = "none"
   self.styleAttributes.stroke_width = nil
   return self
end

function SVGWriter.Style:noFill()
   self.styleAttributes.fill = "none"
   return self
end

function SVGWriter.Style:setOnlyFill(fill, opacity)
   return self:noStroke():setFill(fill, opacity)
end

function SVGWriter.Style:setOnlyStroke(stroke, width, opacity)
   return self:noFill():setStroke(stroke, width, opacity)
end

function SVGWriter.Style:__scanForRefs(refrenceSet, definedSet)
   scanAttributesForRefs(self.styleAttributes, refrenceSet, definedSet)
end

function SVGWriter.Style:setTextAnchorPointMiddle()
   self.styleAttributes.dominant_baseline = "middle"
   self.styleAttributes.text_anchor       = "middle"
   return self
end

local styleClass = {}

styleClass.__canBeStyled = true

function styleClass:setStyle(strokeOrStyle, stroke_width, fill, fill_opacity, stroke_opacity)
   local style
   if getmetatable(strokeOrStyle) == SVGWriter.Style then
      style = strokeOrStyle
      
   else
      style = SVGWriter.Style:new(strokeOrStyle, stroke_width, fill, fill_opacity, stroke_opacity)
   end
   style:apply(self)
   return self
end

function styleClass:__initStyle(style)
   self:clearStyle()
   if style ~= nil then
      self:setStyle(style)
   end
end

function styleClass:clearStyle()
   self.style = SVGWriter.Style:new()
   return self
end

function styleClass:addStyle(style, value)
   self.style:add(style, value)
   return self
end

function styleClass:setFill(fill, opacity)
   self.style:setFill(fill, opacity)
   return self
end

function styleClass:setStroke(stroke, width, opacity)
   self.style:setStroke(stroke, width, opacity)
   return self
end

function styleClass:setOpacity(opacity)
   self.style:setOpacity(opacity)
   return self
end

function styleClass:setStrokeWidth(width)
   self.style:setStrokeWidth(width)
   return self
end

function styleClass:noStroke()
   self.style:noStroke()
   return self
end

function styleClass:noFill()
   self.style:noFill()
   return self
end

function styleClass:setOnlyFill(fill, opacity)
   self.style:setOnlyFill(fill, opacity)
   return self
end

function styleClass:setOnlyStroke(stroke, width, opacity)
   self.style:setOnlyStroke(stroke, width, opacity)
   return self
end


styleClass.__attributeStyleOrder = { "stroke", "stroke-width", "fill",
                                     "marker-start", "marker-mid", 
                                     "marker-end"}


local groupClass = {}
function groupClass:add(svgObject)
   assertDrawableNode(svgObject)
   table.insert(self.children, svgObject)
end

function groupClass:addGroup(...)
   local new = SVGWriter.Group:new(...)
   self:add(new)
   return new
end

function groupClass:addRect(...)
   local new = SVGWriter.Rect:new(...)
   self:add(new)
   return new
end

function groupClass:addCircle(...)
   local new = SVGWriter.Circle:new(...)
   self:add(new)
   return new
end

function groupClass:addEllipse(...)
   local new = SVGWriter.Ellipse:new(...)
   self:add(new)
   return new
end

function groupClass:addLine(...)
   local new = SVGWriter.Line:new(...)
   self:add(new)
   return new
end

function groupClass:addPolygon(...)
   local new = SVGWriter.Polygon:new(...)
   self:add(new)
   return new
end

function groupClass:addPolyline(...)
   local new = SVGWriter.Polyline:new(...)
   self:add(new)
   return new
end

function groupClass:addPath(...)
   local new = SVGWriter.Path:new(...)
   self:add(new)
   return new
end

function groupClass:addText(...)
   local new = SVGWriter.Text:new(...)
   self:add(new)
   return new
end

function groupClass:addUse(...)
   local new = SVGWriter.Use:new(...)
   self:add(new)
   return new
end

function groupClass:__generateChildrenText(lb)
   lb:indent()
   for i, v in ipairs(self.children) do
      v:__generateText(lb)
   end
   lb:unindent()
end

function groupClass:__scanChildrenForRefs(refrenceSet, definedSet)
   for i, v in ipairs(self.children) do
      v:__scanForRefs(refrenceSet, definedSet)
   end
end


--- Group
SVGWriter.Group = {}
SVGWriter.Group.__index = SVGWriter.Group
SVGWriter.Group.__generateAttributeText = generateAttributeTextMethod
SVGWriter.Group.__canBeDrawn = true
copyInto(SVGWriter.Group, transformClass)
copyInto(SVGWriter.Group, styleClass)
copyInto(SVGWriter.Group, groupClass)
copyInto(SVGWriter.Group, refrenceClass)

--- Creates SVG Group
function SVGWriter.Group:new(style)
   local ret = {
      children = {},
      transforms = {}
   }
   setmetatable(ret, self)
   ret:__initStyle(style)
   return ret
end

function SVGWriter.Group:__generateText(lb)
   local attributes = self:__generateAttributeText()
   lb:add(string.format("<g%s>", attributes))
   self:__generateChildrenText(lb)
   lb:add(string.format("</g>", attributes))
end

function SVGWriter.Group:__scanForRefs(refrenceSet, definedSet)
   addSVGObjectToDefinedSet(definedSet, self)
   self.style:__scanForRefs(refrenceSet, definedSet)
   self:__scanChildrenForRefs(refrenceSet, definedSet)
end



--- Document 
SVGWriter.Document = {}
SVGWriter.Document.__index = SVGWriter.Document
SVGWriter.Document.__generateAttributeText = generateAttributeTextMethod
SVGWriter.Document.__attributeTypeOrder = { "width", "height" }
SVGWriter.Document.__canBeDrawn = false
copyInto(SVGWriter.Document, groupClass)

--- Creates SVG Document
function SVGWriter.Document:new(width, height, backgroundStyle)
   local ret = {
      children = {},
      typeAttributes = {
         width  = width,
         height = height
      },
      manualDefs = {}
   }
   setmetatable(ret, self)
   -- Copy over background style
   if backgroundStyle ~= nil then
      ret.backgroundStyle = backgroundStyle:copy()
      -- Remove stroke
      ret.backgroundStyle:noStroke()
   end
   return ret
end

function SVGWriter.Document:setSize(width, height)
   self.typeAttributes.width  = width
   self.typeAttributes.height = height
end

function SVGWriter.Document:addDef(svgDefObject, id)
   assertValidRef(svgDefObject)
   assertSetAdd(self.manualDefs, svgDefObject)
   table.insert(self.manualDefs, svgDefObject)
   if id ~= nil then
      svgDefObject:setID(id)
   end
   return self
end

function SVGWriter.Document:__generateDefsText(lb, missingRefs)
   if next(self.manualDefs) ~= nil or
      next(missingRefs)     ~= nil then
      lb:indent()
      lb:add('<defs>')
      lb:indent()
      
      for i, v in ipairs(self.manualDefs) do
         v:__generateText(lb)
      end
      for i, v in ipairs(missingRefs) do
         v:__generateText(lb)
      end
      
      lb:unindent()
      lb:add('</defs>')
      lb:unindent()
   end
end

function SVGWriter.Document:__generateBackgroundText(lb)
   lb:indent()
   lb:add(string.format('<rect x="0" y="0" width="%s" height="%s" style="%s" />',
                        self.typeAttributes.width, 
                        self.typeAttributes.height,
                        generateAttributeText(self.backgroundStyle.styleAttributes, 
                                              styleClass.__attributeStyleOrder,
                                              true)))
                        
   lb:unindent()
end


--- Returns Generated SVG Document
-- @param indentAmount  The amount of spaces to use as indentation.
--                      -1 has a special mening to not generate newlines
function SVGWriter.Document:createText(indentAmount)
   indentAmount = indentAmount or 2
   
   -- Setup Line Builder for text presentation
   local lb
   if indentAmount < 0 then
      lb = LineBuilder:new(0, "")
   else
      lb = LineBuilder:new(indentAmount, "\n")
   end
   
   -- Scan Document for refrences that need to have ids or need to be put
   -- into the <defs> section
   local refrenceSet = {order={},set={}} 
   local definedSet = {}
   for i, v in ipairs(self.manualDefs) do
      v:__scanForRefs(refrenceSet, definedSet)
   end
   self:__scanChildrenForRefs(refrenceSet, definedSet)
   
   -- Figure out what refs need to be satified and
   -- give refrenced objects ids if they dont have them
   local nextID = 1
   local missingRefs = {}
   for i, ref in ipairs(refrenceSet.order) do
      -- Check to see if we need to create a refrenced Object
      if definedSet[ref] == nil then
         table.insert(missingRefs, ref)
      end
      
      -- Make sure the ref has a good id
      if ref.id == nil then
         ref.idText = string.format("unique-id-%04d", nextID)
         nextID = nextID + 1
      else 
         ref.idText = ref.id
      end
   end
   
   
   -- Create Document
   local attributes = self:__generateAttributeText()
   
   lb:add(string.format('<svg%s xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">', attributes))
   
   -- Generate Defines
   self:__generateDefsText(lb, missingRefs)
   
   -- Generate Background
   if self.typeAttributes.width ~= nil and 
      self.typeAttributes.height ~= nil and 
      self.backgroundStyle ~= nil then
      self:__generateBackgroundText(lb)
   end

   -- Generate All Childeren
   self:__generateChildrenText(lb)
   lb:add('</svg>')
   return lb:get()
end

--- Returns Generated SVG Document and Write to File
-- @param filename      The name of the file to create realative to the
--                      current working directory. You will need to add the
--                      extention.
-- @param indentAmount  The amount of spaces to use as indentation.
--                      -1 has a special mening to not generate newlines
function SVGWriter.Document:writeToFile(filename, indentAmount)
   assert(filename, "Filename needs to be specified")
   local text = self:createText(indentAmount)
   local file = io.open(filename, "w")
   file:write(text)
   file:close()
end

--- Creates SVG Rect
SVGWriter.Rect = {}
SVGWriter.Rect.__index = SVGWriter.Rect
SVGWriter.Rect.__attributeTypeOrder = { "x", "y", "width", "height", "rx", "ry" }
SVGWriter.Rect.__generateAttributeText = generateAttributeTextMethod
SVGWriter.Rect.__canBeDrawn = true
copyInto(SVGWriter.Rect, transformClass)
copyInto(SVGWriter.Rect, styleClass)
copyInto(SVGWriter.Rect, refrenceClass)

function SVGWriter.Rect:new(x, y, width, height, rx, ry, style)
   local ret = {
      transforms = {},
      typeAttributes = {
         x = x,
         y = y,
         width = width,
         height = height,
         rx = rx,
         ry = ry
      }
   }
   setmetatable(ret, self)
   ret:__initStyle(style)
   return ret
end

function SVGWriter.Rect:__generateText(lb)
   local attributes = self:__generateAttributeText()
   lb:add(string.format("<rect%s />", attributes))
end

function SVGWriter.Rect:__scanForRefs(refrenceSet, definedSet)
   addSVGObjectToDefinedSet(definedSet, self)
   self.style:__scanForRefs(refrenceSet, definedSet)
   scanAttributesForRefs(self.typeAttributes, refrenceSet, definedSet)
end


--- Creates SVG Circle
SVGWriter.Circle = {}
SVGWriter.Circle.__index = SVGWriter.Circle
SVGWriter.Circle.__attributeTypeOrder = { "cx", "cy", "r" }
SVGWriter.Circle.__generateAttributeText = generateAttributeTextMethod
SVGWriter.Circle.__canBeDrawn = true
copyInto(SVGWriter.Circle, transformClass)
copyInto(SVGWriter.Circle, styleClass)
copyInto(SVGWriter.Circle, refrenceClass)

function SVGWriter.Circle:new(cx, cy, r, style)
   local ret = {
      typeAttributes = {
         cx = cx,
         cy = cy,
         r = r
      }
   }
   setmetatable(ret, self)
   ret:__initStyle(style)
   return ret
end

function SVGWriter.Circle:__generateText(lb)
   local attributes = self:__generateAttributeText()
   lb:add(string.format("<circle%s />", attributes))
end

function SVGWriter.Circle:__scanForRefs(refrenceSet, definedSet)
   addSVGObjectToDefinedSet(definedSet, self)
   self.style:__scanForRefs(refrenceSet, definedSet)
   scanAttributesForRefs(self.typeAttributes, refrenceSet, definedSet)
end

--- Creates SVG Ellipse
SVGWriter.Ellipse = {}
SVGWriter.Ellipse.__index = SVGWriter.Ellipse
SVGWriter.Ellipse.__attributeTypeOrder = { "cx", "cy", "rx", "ry" }
SVGWriter.Ellipse.__attributeStyleOrder = commonStyleOrder
SVGWriter.Ellipse.__generateAttributeText = generateAttributeTextMethod
SVGWriter.Ellipse.__canBeDrawn = true
copyInto(SVGWriter.Ellipse, transformClass)
copyInto(SVGWriter.Ellipse, styleClass)

function SVGWriter.Ellipse:new(cx, cy, rx, ry, style)
   local ret = {
      transforms = {},
      typeAttributes = {
         cx = cx,
         cy = cy,
         rx = rx,
         ry = ry
      }
   }
   setmetatable(ret, self)
   ret:__initStyle(style)
   return ret
end

function SVGWriter.Ellipse:__generateText(lb)
   local attributes = self:__generateAttributeText()
   lb:add(string.format("<ellipse%s />", attributes))
end

function SVGWriter.Ellipse:__scanForRefs(refrenceSet, definedSet)
   addSVGObjectToDefinedSet(definedSet, self)
   self.style:__scanForRefs(refrenceSet, definedSet)
   scanAttributesForRefs(self.typeAttributes, refrenceSet, definedSet)
end

--- Creates SVG Line
SVGWriter.Line = {}
SVGWriter.Line.__index = SVGWriter.Line
SVGWriter.Line.__attributeTypeOrder = { "x1", "y1", "x2", "y2" }
SVGWriter.Line.__generateAttributeText = generateAttributeTextMethod
SVGWriter.Line.__canBeDrawn = true
copyInto(SVGWriter.Line, transformClass)
copyInto(SVGWriter.Line, styleClass)
copyInto(SVGWriter.Line, refrenceClass)

function SVGWriter.Line:new(x1, y1, x2, y2, style)
   local ret = {
      transforms = {},
      typeAttributes = {
         x1 = x1,
         y1 = y1,
         x2 = x2,
         y2 = y2
      }
   }
   setmetatable(ret, self)
   ret:__initStyle(style)
   return ret
end

function SVGWriter.Line:__generateText(lb)
   local attributes = self:__generateAttributeText()
   lb:add(string.format("<line%s />", attributes))
end

function SVGWriter.Line:__scanForRefs(refrenceSet, definedSet)
   addSVGObjectToDefinedSet(definedSet, self)
   self.style:__scanForRefs(refrenceSet, definedSet)
   scanAttributesForRefs(self.typeAttributes, refrenceSet, definedSet)
end

--- Creates SVG Polygon
SVGWriter.Polygon = {}
SVGWriter.Polygon.__index = SVGWriter.Polygon
SVGWriter.Polygon.__attributeTypeOrder = { "points" }
SVGWriter.Polygon.__generateAttributeText = generateAttributeTextMethod
SVGWriter.Polygon.__canBeDrawn = true
copyInto(SVGWriter.Polygon, transformClass)
copyInto(SVGWriter.Polygon, styleClass)
copyInto(SVGWriter.Polygon, refrenceClass)

-- @param points  Points is an array of struct (x, y).
function SVGWriter.Polygon:new(points, style)
   local ret = {
      transforms = {},
      points = points or {},
      typeAttributes = {
         points = generatePointsText(points)
      }
   }
   setmetatable(ret, self)
   ret:__initStyle(style)
   return ret
end

function SVGWriter.Polygon:add(x, y)
   table.insert(self.points, { x = x, y = y })
   self.typeAttributes.points = generatePointsText(self.points)
   return self
end

function SVGWriter.Polygon:__generateText(lb)
   local attributes = self:__generateAttributeText()
   lb:add(string.format("<polygon%s />", attributes))
end

function SVGWriter.Polygon:__scanForRefs(refrenceSet, definedSet)
   addSVGObjectToDefinedSet(definedSet, self)
   self.style:__scanForRefs(refrenceSet, definedSet)
   scanAttributesForRefs(self.typeAttributes, refrenceSet, definedSet)
end

--- Creates SVG Polyline
SVGWriter.Polyline = {}
SVGWriter.Polyline.__index = SVGWriter.Polyline
SVGWriter.Polyline.__attributeTypeOrder = { "points" }
SVGWriter.Polyline.__generateAttributeText = generateAttributeTextMethod
SVGWriter.Polyline.__canBeDrawn = true
copyInto(SVGWriter.Polyline, transformClass)
copyInto(SVGWriter.Polyline, styleClass)
copyInto(SVGWriter.Polyline, refrenceClass)

-- @param points  Points is an array of struct (x, y).
function SVGWriter.Polyline:new(points, style)
   local ret = {
      transforms = {},
      points = points or {},
      typeAttributes = {
         points = generatePointsText(points)
      }
   }
   setmetatable(ret, self)
   ret:__initStyle(style)
   return ret
end

function SVGWriter.Polyline:add(x, y)
   table.insert(self.points, { x = x, y = y })
   self.typeAttributes.points = generatePointsText(self.points)
   return self
end

function SVGWriter.Polyline:__generateText(lb)
   local attributes = self:__generateAttributeText()
   lb:add(string.format("<polyline%s />", attributes))
end

function SVGWriter.Polyline:__scanForRefs(refrenceSet, definedSet)
   addSVGObjectToDefinedSet(definedSet, self)
   self.style:__scanForRefs(refrenceSet, definedSet)
   scanAttributesForRefs(self.typeAttributes, refrenceSet, definedSet)
end

--- Creates SVG Path
SVGWriter.Path = {}
SVGWriter.Path.__index = SVGWriter.Path
SVGWriter.Path.__attributeTypeOrder = { "d" }
SVGWriter.Path.__generateAttributeText = generateAttributeTextMethod
SVGWriter.Path.__canBeDrawn = true
copyInto(SVGWriter.Path, transformClass)
copyInto(SVGWriter.Path, styleClass)
copyInto(SVGWriter.Path, refrenceClass)

function SVGWriter.Path:new(style)
   local ret = {
      transforms = {},
      commands = {},
      typeAttributes = {
         d = ""
      }
   }
   setmetatable(ret, self)
   ret:__initStyle(style)
   return ret
end

function SVGWriter.Path:addMoveToAbs(x, y)
   local cmd = {x = x, y = y}
   function cmd:generateText()
      return string.format("M%s,%s", tostring(self.x), tostring(self.y))
   end
   table.insert(self.commands, cmd)
   return self
end

function SVGWriter.Path:addMoveToRel(x, y)
   local cmd = {x = x, y = y}
   function cmd:generateText()
      return string.format("m%s,%s", tostring(self.x), tostring(self.y))
   end
   table.insert(self.commands, cmd)
   return self
end

function SVGWriter.Path:addClosePath()
   local cmd = {}
   function cmd:generateText()
      return "Z"
   end
   table.insert(self.commands, cmd)
   return self
end

function SVGWriter.Path:addLineToAbs(x, y)
   local cmd = { x = x, y = y }
   function cmd:generateText()
      return string.format("L%s,%s", tostring(self.x), tostring(self.y))
   end
   table.insert(self.commands, cmd)
   return self
end

function SVGWriter.Path:addLineToRel(x, y)
   local cmd = { x = x, y = y }
   function cmd:generateText()
      return string.format("l%s,%s", tostring(self.x), tostring(self.y))
   end
   table.insert(self.commands, cmd)
   return self
end

function SVGWriter.Path:addHorizontalLineToAbs(x)
   local cmd = { x = x }
   function cmd:generateText()
      return string.format("H%s", tostring(self.x))
   end
   table.insert(self.commands, cmd)
   return self
end

function SVGWriter.Path:addHorizontalLineToRel(x)
   local cmd = { x = x }
   function cmd:generateText()
      return string.format("h%s", tostring(self.x))
   end
   table.insert(self.commands, cmd)
   return self
end

function SVGWriter.Path:addVerticalLineToAbs(y)
   local cmd = { y = y }
   function cmd:generateText()
      return string.format("V%s", tostring(self.y))
   end
   table.insert(self.commands, cmd)
   return self
end

function SVGWriter.Path:addVerticalLineToRel(y)
   local cmd = { y = y }
   function cmd:generateText()
      return string.format("v%s", tostring(self.y))
   end
   table.insert(self.commands, cmd)
   return self
end

function SVGWriter.Path:addCubicCurveToAbs(x, y, cx1, cy1, cx2, cy2)
   local cmd = { 
      x = x, 
      y = y,
      cx1 = cx1,
      cy1 = cy1,
      cx2 = cx2,
      cy2 = cy2
   }
   function cmd:generateText()
      return string.format("C%s,%s %s,%s %s,%s", 
                           tostring(self.cx1), 
                           tostring(self.cy1),
                           tostring(self.cx2),
                           tostring(self.cy2),
                           tostring(self.x),
                           tostring(self.y))
   end
   table.insert(self.commands, cmd)
   return self
end

function SVGWriter.Path:addCubicCurveToRel(x, y, cx1, cy1, cx2, cy2)
   local cmd = { 
      x = x, 
      y = y,
      cx1 = cx1,
      cy1 = cy1,
      cx2 = cx2,
      cy2 = cy2
   }
   function cmd:generateText()
      return string.format("c%s,%s %s,%s %s,%s", 
                           tostring(self.cx1), 
                           tostring(self.cy1),
                           tostring(self.cx2),
                           tostring(self.cy2),
                           tostring(self.x),
                           tostring(self.y))
   end
   table.insert(self.commands, cmd)
   return self
end

function SVGWriter.Path:addNextCubicCurveToAbs(x, y, cx2, cy2)
   local cmd = { 
      x = x, 
      y = y,
      cx2 = cx2,
      cy2 = cy2
   }
   function cmd:generateText()
      return string.format("S%s,%s %s,%s", 
                           tostring(self.cx2),
                           tostring(self.cy2),
                           tostring(self.x),
                           tostring(self.y))
   end
   table.insert(self.commands, cmd)
   return self
end

function SVGWriter.Path:addNextCubicCurveToRel(x, y, cx2, cy2)
   local cmd = { 
      x = x, 
      y = y,
      cx2 = cx2,
      cy2 = cy2
   }
   function cmd:generateText()
      return string.format("s%s,%s %s,%s", 
                           tostring(self.cx2),
                           tostring(self.cy2),
                           tostring(self.x),
                           tostring(self.y))
   end
   table.insert(self.commands, cmd)
   return self
end

function SVGWriter.Path:addQuadraticCurveToAbs(x, y, cx, cy)
   local cmd = { 
      x = x, 
      y = y,
      cx = cx,
      cy = cy
   }
   function cmd:generateText()
      return string.format("Q%s,%s %s,%s", 
                           tostring(self.cx), 
                           tostring(self.cy),
                           tostring(self.x),
                           tostring(self.y))
   end
   table.insert(self.commands, cmd)
   return self
end

function SVGWriter.Path:addQuadraticCurveToRel(x, y, cx, cy)
   local cmd = { 
      x = x, 
      y = y,
      cx = cx,
      cy = cy
   }
   function cmd:generateText()
      return string.format("q%s,%s %s,%s", 
                           tostring(self.cx), 
                           tostring(self.cy),
                           tostring(self.x),
                           tostring(self.y))
   end
   table.insert(self.commands, cmd)
   return self
end

function SVGWriter.Path:addNextQuadraticCurveToAbs(x, y)
   local cmd = { 
      x = x, 
      y = y
   }
   function cmd:generateText()
      return string.format("T%s,%s", 
                           tostring(self.x),
                           tostring(self.y))
   end
   table.insert(self.commands, cmd)
   return self
end

function SVGWriter.Path:addNextQuadraticCurveToRel(x, y)
   local cmd = { 
      x = x, 
      y = y
   }
   function cmd:generateText()
      return string.format("t%s,%s", 
                           tostring(self.x),
                           tostring(self.y))
   end
   table.insert(self.commands, cmd)
   return self
end

function SVGWriter.Path:addArcAbs(x, y, rx, ry, rotation, largeArcFlag, sweepFlag)
   local cmd = { 
      x            = x, 
      y            = y,
      rx           = rx,
      ry           = ry or rx,
      rotation     = rotation or 0,
      largeArcFlag = largeArcFlag,
      sweepFlag    = sweepFlag
   }
   function cmd:generateText()
      local largeArcFlag
      local sweepFlag
      if self.largeArcFlag == "0" or self.largeArcFlag == "1" then
         largeArcFlag = self.largeArcFlag
      else
         if self.largeArcFlag then 
            largeArcFlag = "1" 
         else 
            largeArcFlag = "0" 
         end
      end
      if self.sweepFlag == "0" or self.sweepFlag == "1" then
         sweepFlag = self.sweepFlag
      else
         if self.sweepFlag then 
            sweepFlag = "1" 
         else 
            sweepFlag = "0" 
         end
      end
      return string.format("A%s,%s %s %s,%s %s,%s", 
                           tostring(self.rx),
                           tostring(self.ry),
                           tostring(self.rotation),
                           largeArcFlag,
                           sweepFlag,
                           tostring(self.x),
                           tostring(self.y))
   end
   table.insert(self.commands, cmd)
   return self
end

function SVGWriter.Path:addArcRel(x, y, rx, ry, rotation, largeArcFlag, sweepFlag)
   local cmd = { 
      x            = x, 
      y            = y,
      rx           = rx,
      ry           = ry or rx,
      rotation     = rotation or 0,
      largeArcFlag = largeArcFlag,
      sweepFlag    = sweepFlag
   }
   function cmd:generateText()
      local largeArcFlag
      local sweepFlag
      if self.largeArcFlag == "0" or self.largeArcFlag == "1" then
         largeArcFlag = self.largeArcFlag
      else
         if self.largeArcFlag then 
            largeArcFlag = "1" 
         else 
            largeArcFlag = "0" 
         end
      end
      if self.sweepFlag == "0" or self.sweepFlag == "1" then
         sweepFlag = self.sweepFlag
      else
         if self.sweepFlag then 
            sweepFlag = "1" 
         else 
            sweepFlag = "0" 
         end
      end
      return string.format("a%s,%s %s %s,%s %s,%s", 
                           tostring(self.rx),
                           tostring(self.ry),
                           tostring(self.rotation),
                           largeArcFlag,
                           sweepFlag,
                           tostring(self.x),
                           tostring(self.y))
   end
   table.insert(self.commands, cmd)
   return self
end

function SVGWriter.Path:__generateText(lb)
   local function generatePathText(commands)
      if commands == nil then return "" end
      assert(type(commands) == "table", "Expected parameter commands type is table") 
      local text = ""
      local preSpace = ""
      for i, v in ipairs(commands) do
         text = text .. preSpace .. v:generateText()
         preSpace = " "
      end
      return text
   end
   self.typeAttributes.d = generatePathText(self.commands)
   local attributes = self:__generateAttributeText()
   lb:add(string.format("<path%s />", attributes))
end

function SVGWriter.Path:__scanForRefs(refrenceSet, definedSet)
   addSVGObjectToDefinedSet(definedSet, self)
   self.style:__scanForRefs(refrenceSet, definedSet)
   scanAttributesForRefs(self.typeAttributes, refrenceSet, definedSet)
end


--- Creates SVG Text
SVGWriter.Text = {}
SVGWriter.Text.__index = SVGWriter.Text
SVGWriter.Text.__attributeTypeOrder = { "x", "y" }
SVGWriter.Text.__generateAttributeText = generateAttributeTextMethod
SVGWriter.Text.__canBeDrawn = true
copyInto(SVGWriter.Text, transformClass)
copyInto(SVGWriter.Text, styleClass)
copyInto(SVGWriter.Text, refrenceClass)
SVGWriter.Text.__attributeStyleOrder = 
      mergeIntoNew(styleClass.__attributeStyleOrder,
                   { "text-anchor", "dominant-baseline" }) 

function SVGWriter.Text:new(text, x, y, style)
   local ret = {
      transforms = {},
      typeAttributes = {
         x = x,
         y = y
      },
      text = text
   }
   setmetatable(ret, self)
   ret:__initStyle(style)
   return ret
end

function SVGWriter.Text:setText(text)
   self.text = tostring(text)
   return self
end

function SVGWriter.Text:setAnchorPointMiddle()
   self.style:setTextAnchorPointMiddle()
   return self
end

function SVGWriter.Text:__generateText(lb)
   local attributes = self:__generateAttributeText()
   lb:add(string.format("<text%s>%s</text>", attributes, self.text))
end

function SVGWriter.Text:__scanForRefs(refrenceSet, definedSet)
   addSVGObjectToDefinedSet(definedSet, self)
   self.style:__scanForRefs(refrenceSet, definedSet)
   scanAttributesForRefs(self.typeAttributes, refrenceSet, definedSet)
end

--- Creates SVG Use
SVGWriter.Use = {}
SVGWriter.Use.__index = SVGWriter.Use
SVGWriter.Use.__attributeTypeOrder = { "xlink:href", "x", "y", "width", "height" }
SVGWriter.Use.__generateAttributeText = generateAttributeTextMethod
SVGWriter.Use.__canBeDrawn = true
copyInto(SVGWriter.Use, transformClass)
copyInto(SVGWriter.Use, styleClass)
copyInto(SVGWriter.Use, refrenceClass)

function SVGWriter.Use:new(href, x, y, width, height, style)
   local ret = {
      transforms = {},
      href = href,
      typeAttributes = {
         x = x,
         y = y,
         width = width,
         height = height
      }
   }
   setmetatable(ret, self)
   ret:__initStyle(style)

   return ret
end

function SVGWriter.Use:__generateText(lb)
   -- At the last possible moment set up the href
   if type(self.href) == "string" then
      self.typeAttributes["xlink:href"] = string.format("#%s", self.href)
   elseif type(self.href) == "table" then
      self.typeAttributes["xlink:href"] = string.format("#%s", self.href.idText)
   end
   local attributes = self:__generateAttributeText()
   lb:add(string.format("<use%s />", attributes))
end

function SVGWriter.Use:__scanForRefs(refrenceSet, definedSet)
   addSVGObjectToDefinedSet(definedSet, self)
   self.style:__scanForRefs(refrenceSet, definedSet)
   scanAttributesForRefs(self.typeAttributes, refrenceSet, definedSet)
   if type(self.href) == "table" then   
      addSVGObjectToRefrenceSet(refrenceSet, self.href)
      self.href:__scanForRefs(refrenceSet, nil)
   end
end

local stopsClass = {}

function stopsClass:setStops(stops)
   self.stops = {}
   self.resetRamp = true

   if stops then
      local stopType = type(stops)
      if stopType == "string" then
         -- Assumes one color fade into transparancy
         table.insert(self.stops, { offset="0%",   color=stops, opacity=1 })
         table.insert(self.stops, { offset="100%", color=stops, opacity=0 })
      elseif stopType == "table" then
         for i, v in ipairs(stops) do
            local vType = type(v)
            if vType == "string" then
               table.insert(ret.stops, { offset=nil, color=v, opacity=1 })
            elseif vType == "table" then
               assert(v.color, "Expected Color in subtable")
               table.insert(self.stops, { offset=v.offset, color=v.color, opacity=v.opacity or 1 })               
            else
               assert(false, string.format("Type of element %d of stops needs to a string or a table", i))
            end
         end
      else
         assert(false, "stops parameter is not a table containing data or color")
      end
   else
      table.insert(self.stops, { offset="0%",   color="black", opacity=1 })
      table.insert(self.stops, { offset="100%", color="white", opacity=0 })
   end
   return self
end

function stopsClass:addStop(color, opacity, offset)
   if self.resetRamp then
      self.resetRamp = false
      self.stops = {}
   end
   table.insert(self.stops, 
                { offset=offset, color=color, opacity=opacity or 1 })
   return self
end

function stopsClass:__respaceGradient()
   for i, v in ipairs(self.stops) do
      -- TODO: Make this more useful
      v.__computedOffset = v.offset
   end
end

function stopsClass:__generatedStopsText(lb)
   lb:indent()
   for i, v in ipairs(self.stops) do
      lb:add(string.format('<stop offset="%s" style="stop-color:%s;stop-opacity:%s;" />',
                           tostring(v.__computedOffset),
                           tostring(v.color),
                           tostring(v.opacity)))
   end
   lb:unindent()
end

--- Creates SVG LinearGradient
SVGWriter.LinearGradient = {}
SVGWriter.LinearGradient.__index = SVGWriter.LinearGradient
SVGWriter.LinearGradient.__attributeTypeOrder = { "x1", "y1", "x2", "y2" }
SVGWriter.LinearGradient.__generateAttributeText = generateAttributeTextMethod
SVGWriter.LinearGradient.__canBeDrawn = false
copyInto(SVGWriter.LinearGradient, stopsClass)
copyInto(SVGWriter.LinearGradient, refrenceClass)

function SVGWriter.LinearGradient:new(stops, x1, y1, x2, y2)
   local ret = {
      stops = {},
      typeAttributes = {
         x1 = x1,
         y1 = y1,
         x2 = x2,
         y2 = y2,
      },
      resetRamp = false
   }
   setmetatable(ret, self)
  
   ret:setStops(stops)

   return ret
end

function SVGWriter.LinearGradient:__generateText(lb)
   -- Compute missing offsets
   self:__respaceGradient()
   local attributes = self:__generateAttributeText()
   lb:add(string.format("<linearGradient%s>", attributes))
   self:__generatedStopsText(lb)
   lb:add("</linearGradient>")
end

function SVGWriter.LinearGradient:__scanForRefs(refrenceSet, definedSet)
   addSVGObjectToDefinedSet(definedSet, self)
   scanAttributesForRefs(self.typeAttributes, refrenceSet, definedSet)
end

--- Creates SVG RadialGradient
SVGWriter.RadialGradient = {}
SVGWriter.RadialGradient.__index = SVGWriter.RadialGradient
SVGWriter.RadialGradient.__attributeTypeOrder = { "cx", "cy", "r", "fx", "fy" }
SVGWriter.RadialGradient.__generateAttributeText = generateAttributeTextMethod
SVGWriter.RadialGradient.__canBeDrawn = false
copyInto(SVGWriter.RadialGradient, stopsClass)
copyInto(SVGWriter.RadialGradient, refrenceClass)

function SVGWriter.RadialGradient:new(stops, cx, cy, r, fx, fy)
   local ret = {
      stops = {},
      typeAttributes = {
         cx = cx,
         cy = cy,
         r = r,
         fx = fx,
         fy = fy,
      },
      resetRamp = false
   }
   setmetatable(ret, self)
  
   ret:setStops(stops)

   return ret
end

function SVGWriter.RadialGradient:__generateText(lb)
   -- Compute missing offsets
   self:__respaceGradient()
   local attributes = self:__generateAttributeText()
   lb:add(string.format("<radialGradient%s>", attributes))
   self:__generatedStopsText(lb)
   lb:add("</radialGradient>")
end

function SVGWriter.RadialGradient:__scanForRefs(refrenceSet, definedSet)
   addSVGObjectToDefinedSet(definedSet, self)
   scanAttributesForRefs(self.typeAttributes, refrenceSet, definedSet)
end

--- Creates SVG Marker
SVGWriter.Marker = {}
SVGWriter.Marker.__index = SVGWriter.Marker
SVGWriter.Marker.__attributeTypeOrder = { "markerWidth", "markerHeight", 
                                              "refX", "refY", "orient", 
                                              "markerUnits" }
SVGWriter.Marker.__generateAttributeText = generateAttributeTextMethod
SVGWriter.Marker.__canBeDrawn = false
copyInto(SVGWriter.Marker, styleClass)
copyInto(SVGWriter.Marker, groupClass)
copyInto(SVGWriter.Marker, refrenceClass)

--- Marker
function SVGWriter.Marker:new(markerWidth, markerHeight, refX, refY, orient, markerUnits, style)
   local ret = {
      children = {},
      typeAttributes = {
         markerWidth = markerWidth,
         markerHeight = markerHeight,
         refX = refX,
         refY = refY,
         orient = orient,
         markerUnits = markerUnits
      }
   }
   setmetatable(ret, self)
   ret:__initStyle(style)
   return ret
end

function SVGWriter.Marker:__generateText(lb)
   local attributes = self:__generateAttributeText()
   lb:add(string.format("<marker%s>", attributes))
   self:__generateChildrenText(lb)
   lb:add(string.format("</marker>", attributes))
end

function SVGWriter.Marker:__scanForRefs(refrenceSet, definedSet)
   addSVGObjectToDefinedSet(definedSet, self)
   self.style:__scanForRefs(refrenceSet, definedSet)
   scanAttributesForRefs(self.typeAttributes, refrenceSet, definedSet)
   self:__scanChildrenForRefs(refrenceSet, definedSet)
end


--- Creates SVG Pattern
SVGWriter.Pattern = {}
SVGWriter.Pattern.__index = SVGWriter.Pattern
SVGWriter.Pattern.__attributeTypeOrder = { "x", "y", "width", "height", 
                                              "patternUnits", 
                                              "patternContentUnits" }
SVGWriter.Pattern.__generateAttributeText = generateAttributeTextMethod
SVGWriter.Pattern.__canBeDrawn = false
copyInto(SVGWriter.Pattern, styleClass)
copyInto(SVGWriter.Pattern, groupClass)
copyInto(SVGWriter.Pattern, refrenceClass)

--- Pattern
function SVGWriter.Pattern:new(x, y, width, height, patternUnits, patternContentUnits)
   local ret = {
      children = {},
      typeAttributes = {
         x = x,
         y = y,
         width = width,
         height = height,
         patternUnits = patternUnits,
         patternContentUnits = patternContentUnits
      }
   }
   setmetatable(ret, self)
   ret:setStyle(nil)
   return ret
end

function SVGWriter.Pattern:__generateText(lb)
   local attributes = self:__generateAttributeText()
   lb:add(string.format("<pattern%s>", attributes))
   self:__generateChildrenText(lb)
   lb:add(string.format("</pattern>", attributes))
end

function SVGWriter.Pattern:__scanForRefs(refrenceSet, definedSet)
   addSVGObjectToDefinedSet(definedSet, self)
   self.style:__scanForRefs(refrenceSet, definedSet)
   scanAttributesForRefs(self.typeAttributes, refrenceSet, definedSet)
   self:__scanChildrenForRefs(refrenceSet, definedSet)
end

return SVGWriter
