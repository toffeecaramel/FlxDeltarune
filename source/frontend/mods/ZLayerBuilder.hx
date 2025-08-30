package frontend.mods;

import sys.io.File;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import flixel.tile.FlxTile;
import flixel.FlxSprite;
import openfl.geom.Rectangle;
import Lambda;

class ZLayerBuilder {

    /**
     * Builds an FlxGroup of sprites representing all tiles overlapped by the polygon on a given tile layer.
     * @param polygonPoints World coords polygon from object layer.
     * @param tileLayer The FlxTilemap layer (must be loaded and visible).
     * @param tileSize Tile size (assumes square).
     * @param layerOffsetX Tile layer pixel offset X.
     * @param layerOffsetY Tile layer pixel offset Y.
     */
    public static function buildZLayerGroup(
        polygonPoints:Array<FlxPoint>,
        tileLayer:FlxTilemap,
        graphicPath:String,
        tileSize:Int,
        layerOffsetX:Float = 0,
        layerOffsetY:Float = 0
    ):FlxSpriteGroup {

        var group = new FlxSpriteGroup();

        var localPoly = polygonPoints.map(p -> new FlxPoint(p.x - layerOffsetX, p.y - layerOffsetY));

        var minX = Lambda.fold(localPoly, (p, acc) -> Math.min(p.x, acc), localPoly[0].x);
        var maxX = Lambda.fold(localPoly, (p, acc) -> Math.max(p.x, acc), localPoly[0].x);
        var minY = Lambda.fold(localPoly, (p, acc) -> Math.min(p.y, acc), localPoly[0].y);
        var maxY = Lambda.fold(localPoly, (p, acc) -> Math.max(p.y, acc), localPoly[0].y);
        

        var leftTile = Math.floor(minX / tileSize);
        var rightTile = Math.floor(maxX / tileSize);
        var topTile = Math.floor(minY / tileSize);
        var bottomTile = Math.floor(maxY / tileSize);

        for (ty in topTile...bottomTile + 1) {
            for (tx in leftTile...rightTile + 1) {

                var tileRect = new Rectangle(tx * tileSize, ty * tileSize, tileSize, tileSize);

                if (polygonIntersectsRect(localPoly, tileRect)) {
                    var tileIndex = tileLayer.getTileIndex(tx, ty);
                    if(tileIndex <= 0) continue; // skip empty tile
                    tileIndex += 1;

                    if (tileIndex > 0) {

                        var sprite = new FlxSprite(tx * tileSize + layerOffsetX, ty * tileSize + layerOffsetY);

                        // Flixels stupid cache..
                        var rawBytes = File.getBytes(graphicPath);
                        var rawBitmap = BitmapData.fromBytes(rawBytes);
                        var tileGraphic = FlxGraphic.fromBitmapData(rawBitmap);

                        var tileWidth = tileLayer.tileWidth;
                        var tileHeight = tileLayer.tileHeight;

                        var tilesPerRow = Std.int(tileGraphic.width / tileWidth);
                        var tileID = tileIndex - 1;
                        var frameX = (tileID % tilesPerRow) * tileWidth;
                        var frameY = Math.floor(tileID / tilesPerRow) * tileHeight;

                        sprite.loadGraphic(tileGraphic, true, tileWidth, tileHeight);
                        sprite.animation.frameIndex = tileID;


                        sprite.x = tx * tileSize + layerOffsetX;
                        sprite.y = ty * tileSize + layerOffsetY;

                        group.add(sprite);
                    }
                }
            }
        }

        return group;
    }

    static function polygonIntersectsRect(polygon:Array<FlxPoint>, rect:Rectangle):Bool {
        for (p in polygon) {
            if (rect.contains(p.x, p.y)) return true;
        }

        var corners = [
            new FlxPoint(rect.x, rect.y),
            new FlxPoint(rect.x + rect.width, rect.y),
            new FlxPoint(rect.x + rect.width, rect.y + rect.height),
            new FlxPoint(rect.x, rect.y + rect.height)
        ];
        for (corner in corners) {
            if (pointInPolygon(corner, polygon)) return true;
        }

        if (edgesIntersect(polygon, rect)) return true;

        return false;
    }

    static function pointInPolygon(point:FlxPoint, polygon:Array<FlxPoint>):Bool {
        var inside = false;
        var j = polygon.length - 1;
        for (i in 0...polygon.length) {
            var pi = polygon[i];
            var pj = polygon[j];
            if (((pi.y > point.y) != (pj.y > point.y)) &&
                (point.x < (pj.x - pi.x) * (point.y - pi.y) / (pj.y - pi.y) + pi.x)) {
                inside = !inside;
            }
            j = i;
        }
        return inside;
    }

    static function edgesIntersect(polygon:Array<FlxPoint>, rect:Rectangle):Bool {
        for (i in 0...polygon.length) {
            var p1 = polygon[i];
            var p2 = polygon[(i + 1) % polygon.length];

            var rectEdges = [
                {start: new FlxPoint(rect.x, rect.y), end: new FlxPoint(rect.x + rect.width, rect.y)},
                {start: new FlxPoint(rect.x + rect.width, rect.y), end: new FlxPoint(rect.x + rect.width, rect.y + rect.height)},
                {start: new FlxPoint(rect.x + rect.width, rect.y + rect.height), end: new FlxPoint(rect.x, rect.y + rect.height)},
                {start: new FlxPoint(rect.x, rect.y + rect.height), end: new FlxPoint(rect.x, rect.y)}
            ];

            for (edge in rectEdges) {
                if (lineSegmentsIntersect(p1, p2, edge.start, edge.end)) return true;
            }
        }
        return false;
    }

    static function lineSegmentsIntersect(p1:FlxPoint, p2:FlxPoint, p3:FlxPoint, p4:FlxPoint):Bool {
        var s1_x = p2.x - p1.x;
        var s1_y = p2.y - p1.y;
        var s2_x = p4.x - p3.x;
        var s2_y = p4.y - p3.y;

        var s = (-s1_y * (p1.x - p3.x) + s1_x * (p1.y - p3.y)) / (-s2_x * s1_y + s1_x * s2_y);
        var t = ( s2_x * (p1.y - p3.y) - s2_y * (p1.x - p3.x)) / (-s2_x * s1_y + s1_x * s2_y);

        return s >= 0 && s <= 1 && t >= 0 && t <= 1;
    }
}
