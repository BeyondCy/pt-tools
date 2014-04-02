/*
    Add text to a new chunk in a PNG picture. 
    Useful for testing image uplaod features.
*/

<?php   

    addTextToPngFile($argv[1], $argv[2], "Watermark", "Hi this is a TEXT test");

    function addTextToPngFile($pngSrc,$pngTarget,$key,$text) {
        $chunk = phpTextChunk($key,$text);
        $png = file_get_contents($pngSrc);
        $png2 = addPngChunk($chunk,$png);
        file_put_contents($pngTarget,$png2);
    }

    // creates a tEXt chunk with given key and text (iso8859-1)
    // ToDo: check that key length is less than 79 and that neither includes null bytes
    function phpTextChunk($key,$text) {
        $chunktype = "tEXt";
        $chunkdata = $key . "\0" . $text;
        $crc = pack("N", crc32($chunktype . $chunkdata));
        $len = pack("N",strlen($chunkdata));
        return $len .  $chunktype  . $chunkdata . $crc;
    }

    // inserts chunk before IEND chunk (last 12 bytes)
    function addPngChunk($chunk,$png) {
        $len = strlen($png);
        return substr($png,0,$len-12) . $chunk . substr($png,$len-12,12);
    }

?>
