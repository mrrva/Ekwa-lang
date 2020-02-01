<?php
$script = file_get_contents("./test.ekwa");
$lines = explode("\n", $script);
$filename = "./instructions";
$bytecode = NULL;

$tokens = array(
	"EKWA_FUNC"		=> "\x01",
	"EKWA_FARG"		=> "\x02",
	"EKWA_VAR"		=> "\x03",
	"EKWA_SHOW"		=> "\x04",
	"EKWA_RET"		=> "\x05",
	"EKWA_VAL"		=> "\x06",
	"EKWA_CALL"		=> "\x07",
	"EKWA_JMP"		=> "\x08",
	"EKWA_FSET"		=> "\x09",
	"EKWA_WRT"		=> "\x0a",
	"EKWA_BUFF"		=> "\x0b",
	"EKWA_PBUF"		=> "\x0c",
	"EKWA_IFE"		=> "\x0d",
	"EKWA_IFNE"		=> "\x0e",
	"EKWA_IFS"		=> "\x0f",
	"EKWA_IFB"		=> "\x10",
	"EKWA_INFO"		=> "\x11",
	"EKWA_RMV"		=> "\x12",
	"EKWA_CAT"		=> "\x13",
	"EKWA_EXIT"		=> "\x14",
	"EKWA_ARG"		=> "\x15",
	"EKWA_ARGL"		=> "\x16",

	"EKWA_ADD"		=> "\x17",
	"EKWA_SUB"		=> "\x18",
	"EKWA_DIV"		=> "\x19",
	"EKWA_MOD"		=> "\x1a",
	"EKWA_MUL"		=> "\x1b",
	"EKWA_SAL"		=> "\x1c",
	"EKWA_SAR"		=> "\x1d",

	"EKWA_END"		=> "\x1e"
);

$types = array(
	"EKWA_STRING"	=> "\x00",
	"EKWA_BOOL"		=> "\x01",
	"EKWA_ARRAY"	=> "\x02",
	"EKWA_INT"		=> "\x03",
	"EKWA_FLOAT"	=> "\x04"
);

$vars = array();

foreach ($lines as $line) {
	$elements = explode("\t", $line);

	if (!isset($tokens[$elements[0]])) {
		continue;
	}

	$bytecode .= $tokens[$elements[0]];

	if (!isset($elements[1])) {
		$bytecode .= "\x00\x00";
		continue;
	}

	$length = strlen($elements[1]);
	$bytecode .= pack('n', $length);
	$bytecode .= $elements[1];

	if (!isset($elements[2])) {
		$bytecode .= "\x00\x00";
		continue;
	}

	if (isset($types[$elements[2]])
		&& $elements[0] == "EKWA_VAR") {
		$bytecode .= "\x00\x01";
		$bytecode .= $types[$elements[2]];
		$vars[$elements[1]] = $elements[2];
		continue;
	}

	if ($elements[0] == "EKWA_VAL"
		&& $vars[$elements[1]] == "EKWA_INT") {
		$d_bytes = pack('i', (int)$elements[2]);
		$bytecode .= pack('n', strlen($d_bytes));
		$bytecode .= $d_bytes;
		continue;
	}

	if ($elements[0] == "EKWA_VAL"
		&& $vars[$elements[1]] == "EKWA_FLOAT") {
		$d_bytes = pack('f', (float)$elements[2]);
		$bytecode .= pack('n', strlen($d_bytes));
		$bytecode .= $d_bytes;
		continue;
	}

	$length = strlen($elements[2]);
	$bytecode .= pack('n', $length);
	$bytecode .= (string)$elements[2];
}

$fp = fopen($filename, "wb");
fwrite($fp, $bytecode);
fclose($fp);
