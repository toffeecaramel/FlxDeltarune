package backend;

import haxe.Json;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import haxe.zip.Compress;
import haxe.zip.Uncompress;
import sys.io.File;

/**
 * Class meant to handle Room data.
 * Such as tilemap being used, collisions,
 * events, etcetera.
 * Also, it's in binary because I really wanted to give binary stuff a try haha.
 **/
class Room
{
    /**
     * Saves a room file.
     * @param roomData A Room Data structure.
     * @param filePath Where the room will be saved at.
     **/
    public static function save(roomData:RoomData, filePath:String):Void
    {
        var output = new BytesOutput();

        // OMG OMG OMG THIS WORKS OMGGGGGG I'M SO HAPPYYYYY
    	// This was a fun experience.
    	// Last test is to see how long it takes to load the file.

    	// ok so best I got was 0.999999999999446 ms
    	// very decent, hm?
    	// (my pc is low end btw.)
    	/**
			Intel(R) Core(TM) i3-10110U CPU @ 2.10GHz   2.59 GHz
			4,00 GB (usable: 3,82 GB)
    	 **/
    	// but, yeah! overall happy with the result. feel free to take a lookie
        
        // write header
        output.writeString("ROOM"); // 4 bytes magic :D
        output.writeByte(1); // version I think?
        
        // write tileset, music, resetMusic
        writeStringBytes(roomData.tileset, output);
        writeStringBytes(roomData.music, output);
        output.writeByte(roomData.resetMusic ? 1 : 0); // bool as byte
        
        // write layers
        output.writeInt32(roomData.layers.length);
        for (layer in roomData.layers)
            writeStringBytes(layer, output);
        
        // write tiles
        output.writeInt32(roomData.tiles.length);
        for (tile in roomData.tiles)
        {
            writeStringBytes(tile.layer, output); // write new layer field
            output.writeFloat(tile.pos[0]);
            output.writeFloat(tile.pos[1]);
            output.writeFloat(tile.size[0]);
            output.writeFloat(tile.size[1]);
            writeStringBytes(tile.tag, output);
        }
        
        // write events
        output.writeInt32(roomData.events.length);
        for (event in roomData.events)
        {
            writeStringBytes(event.name, output);
            writeStringBytes(event.tag, output);
            
            output.writeFloat(event.pos[0]);
            output.writeFloat(event.pos[1]);
            output.writeFloat(event.triggerArea[0]);
            output.writeFloat(event.triggerArea[1]);
            
            output.writeByte(event.triggerOnce ? 1 : 0);
            
            // Write values with Int32 length prefix to match load
            final valuesBytes = Bytes.ofString(Json.stringify(event.values));
            output.writeInt32(valuesBytes.length); // Use Int32 for values
            output.writeBytes(valuesBytes, 0, valuesBytes.length);
        }
        
        // then we compress it and save!
        File.saveBytes(Asset.getPath(filePath, null), Compress.run(output.getBytes(), 6));
    }

    /**
     * Loads a room file and returns it.
     * @param filePath Where the room will be loaded from.
     **/
    public static function load(filePath:String):RoomData
    {
        // load and uncompress (huge)
        var input = new BytesInput(Uncompress.run(File.getBytes(Asset.getPath(filePath, null))));
        
        // read header
        if (input.readString(4) != "ROOM") throw "Invalid room file";
        final version = input.readByte();
        
        // read tileset, music, resetMusic
        var tileset = input.readString(input.readInt16());
        var music = input.readString(input.readInt16());
        var resetMusic = input.readByte() == 1;
        
        // read layers
        var layers:Array<String> = [];
        for (i in 0...input.readInt32())
        {
            layers.push(input.readString(input.readInt16()));
        }
        
        // read tiles
        var tiles:Array<Tile> = [];
        for (i in 0...input.readInt32())
        {
            tiles.push({
                layer: input.readString(input.readInt16()), // read new layer field
                pos: [input.readFloat(), input.readFloat()], 
                size: [input.readFloat(), input.readFloat()], 
                tag: input.readString(input.readInt16())
            });
        }
        
        // read events
        var events:Array<Event> = [];
        for (i in 0...input.readInt32())
        {
            events.push({
                name: input.readString(input.readInt16()), 
                tag: input.readString(input.readInt16()), 
                pos: [input.readFloat(), input.readFloat()], 
                triggerArea: [input.readFloat(), input.readFloat()],
                triggerOnce: input.readByte() == 1,
                values: Json.parse(input.readString(input.readInt32()))
            });
        }
        
        return {
            tileset: tileset, 
            music: music, 
            resetMusic: resetMusic, 
            layers: layers, 
            tiles: tiles, 
            events: events
        };
    }

    // just so I dont need to repeat these 3 lines over and over
    private static function writeStringBytes(stringOut:String, output:BytesOutput)
    {
        final bytes = Bytes.ofString(stringOut);
        output.writeInt16(bytes.length);
        output.writeBytes(bytes, 0, bytes.length);
    }
}

typedef RoomData = {
    var tileset:String;
    var music:String;
    var resetMusic:Bool;
    var layers:Array<String>;
    var tiles:Array<Tile>;
    var events:Array<Event>;
}

typedef Tile = {
    var layer:String;
    var pos:Array<Float>;
    var size:Array<Float>;
    var tag:String;
}

typedef Event = {
    var name:String;
    var tag:String;
    var pos:Array<Float>;
    var triggerArea:Array<Float>;
    var triggerOnce:Bool;
    var values:Dynamic;
}