﻿package com.codeazur.as3swf.data
{
	import com.codeazur.as3swf.SWFData;
	
	public class SWFTextRecord
	{
		public var type:uint;
		public var hasFont:Boolean;
		public var hasColor:Boolean;
		public var hasXOffset:Boolean;
		public var hasYOffset:Boolean;
		
		public var fontId:uint;
		public var textColor:uint;
		public var textHeight:uint;
		public var xOffset:int;
		public var yOffset:int;
		
		protected var _glyphEntries:Vector.<SWFGlyphEntry>;
		
		public function SWFTextRecord(data:SWFData = null, glyphBits:uint = 0, advanceBits:uint = 0, previousRecord:SWFTextRecord = null, level:uint = 1) {
			_glyphEntries = new Vector.<SWFGlyphEntry>();
			if (data != null) {
				parse(data, glyphBits, advanceBits, previousRecord, level);
			}
		}
		
		public function get glyphEntries():Vector.<SWFGlyphEntry> { return _glyphEntries; }
		
		public function parse(data:SWFData, glyphBits:uint, advanceBits:uint, previousRecord:SWFTextRecord = null, level:uint = 1):void {
			var styles:uint = data.readUI8();
			type = styles >> 7;
			hasFont = ((styles & 0x08) != 0);
			hasColor = ((styles & 0x04) != 0);
			hasYOffset = ((styles & 0x02) != 0);
			hasXOffset = ((styles & 0x01) != 0);
			if (hasFont) {
				fontId = data.readUI16();
			} else if (previousRecord != null) {
				fontId = previousRecord.fontId;
			}
			if (hasColor) {
				textColor = (level < 2) ? data.readRGB() : data.readRGBA();
			} else if (previousRecord != null) {
				textColor = previousRecord.textColor;
			}
			if (hasXOffset) {
				xOffset = data.readSI16();
			} else if (previousRecord != null) {
				xOffset = previousRecord.xOffset;
			}
			if (hasYOffset) {
				yOffset = data.readSI16();
			} else if (previousRecord != null) {
				yOffset = previousRecord.yOffset;
			}
			if (hasFont) {
				textHeight = data.readUI16();
			} else if (previousRecord != null) {
				textHeight = previousRecord.textHeight;
			}
			var glyphCount:uint = data.readUI8();
			for (var i:uint = 0; i < glyphCount; i++) {
				_glyphEntries.push(data.readGLYPHENTRY(glyphBits, advanceBits));
			}
		}
		
		public function publish(data:SWFData, glyphBits:uint, advanceBits:uint, previousRecord:SWFTextRecord = null, level:uint = 1):void {
			var flags:uint = (type << 7);
			hasFont = (previousRecord == null
				|| (previousRecord.fontId != fontId)
				|| (previousRecord.textHeight != textHeight));
			hasColor = (previousRecord == null || (previousRecord.textColor != textColor));
			hasXOffset = (previousRecord == null || (previousRecord.xOffset != xOffset));
			hasYOffset = (previousRecord == null || (previousRecord.yOffset != yOffset));
			if(hasFont) { flags |= 0x08; }
			if(hasColor) { flags |= 0x04; }
			if(hasYOffset) { flags |= 0x02; }
			if(hasXOffset) { flags |= 0x01; }
			data.writeUI8(flags);
			if(hasFont) {
				data.writeUI16(fontId);
			}
			if(hasColor) {
				if(level >= 2) {
					data.writeRGBA(textColor);
				} else {
					data.writeRGB(textColor);
				}
			}
			if(hasXOffset) {
				data.writeSI16(xOffset);
			}
			if(hasYOffset) {
				data.writeSI16(yOffset);
			}
			if(hasFont) {
				data.writeUI16(textHeight);
			}
			var glyphCount:uint = _glyphEntries.length;
			data.writeUI8(glyphCount);
			for (var i:uint = 0; i < glyphCount; i++) {
				data.writeGLYPHENTRY(_glyphEntries[i], glyphBits, advanceBits);
			}
		}
		
		public function toString():String {
			var params:Array = ["Glyphs: " + _glyphEntries.length.toString()];
			if (hasFont) { params.push("FontID: " + fontId); params.push("Height: " + textHeight); }
			if (hasColor) { params.push("Color: " + textColor.toString(16)); }
			if (hasXOffset) { params.push("XOffset: " + xOffset); }
			if (hasYOffset) { params.push("YOffset: " + yOffset); }
			return params.join(", ");
		}
	}
}
