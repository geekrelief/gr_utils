package gr.display {
    import flash.display.BitmapData;
    
    // returns an instance of BitmapData that's transparent
    public function newBitmapData(_width:int, _height:int):BitmapData {
        return new BitmapData(_width, _height, true, 0x00000000);
    }
}
