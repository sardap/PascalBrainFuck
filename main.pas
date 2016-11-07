program PascalBrainFuck;

uses
  SysUtils;

const
	WRITE_FILE = 'test.pas';

function HowManyInFile(var fileName: UnicodeString; checkChar: AnsiChar): Integer;
var
	i : Integer;
	temp : String;
	readingFile : TextFile;

begin
	AssignFile(readingFile, fileName);
	Reset(readingFile);
	result := 0;
	while not eof(readingFile) do
	begin
		ReadLn(readingFile, temp);
		for i:=0 to Length(temp) do
		begin
			if temp[i] = checkChar then
				result += 1;
		end;
	end;
	CloseFile(readingFile);
end;

function HowManyUntilNext(var toRead: AnsiString; var idx: Integer; toCheck: AnsiChar): Byte;
begin
	result := 0;
	while (toRead[idx] = toCheck) do
	begin
		result += 1;
		idx += 1;
	end;
	idx -= 1;
end;

procedure DeleteGarbage(var code: AnsiString; offset: Integer);
begin
	if (code[offset] = Chr(32)) or (code[offset] = Chr(9)) or (code[offset] = Chr(13)) then
		Delete(code, offset, 1);
	if offset < Length(code) then
		DeleteGarbage(code, offset + 1);
end;

procedure ReadBrainFuckCode(var toRead: AnsiString; var writeFile : TextFile);
var
	i : Integer;

begin
	i := 0;
	while i <= Length(toRead) do
	begin
		case toRead[i] of
			'>'	:  WriteLn(writeFile,'	i +=', HowManyUntilNext(toRead, i, '>'), ';');
			'<'	: WriteLn(writeFile, '	i -=', HowManyUntilNext(toRead, i, '<'), ';');
			'+'	: WriteLn(writeFile, '	boxs[i] +=', HowManyUntilNext(toRead, i, '+'), ';');
			'-'	: WriteLn(writeFile, '	boxs[i] -=', HowManyUntilNext(toRead, i, '-'), ';');
			'.'	: WriteLn(writeFile, '	Write(Chr(boxs[i]));');
			','	: WriteLn(writeFile, '	Read(boxs[i]);');
			'['	: begin
				 			WriteLn(writeFile, '	while(boxs[i] <> 0) do');
							WriteLn(writeFile, '	begin');
						end;
			']'	: WriteLn(writeFile, '	end;');
		end;
		i += 1;
	end;
end;

procedure ReadFile(fileName: UnicodeString);
var
	readingLine, brainFuckCode: AnsiString;
	readingFile : TextFile;
	writeFile : TextFile;
	writeFileName : UnicodeString;

begin
	writeFileName := 'test.pas';
	WriteLn('Creating ', writeFileName);
	AssignFile(writeFile, writeFileName);
	Rewrite(writeFile);
	WriteLn(writeFile, 'program test;');
	WriteLn(writeFile, 'uses');
	WriteLn(writeFile, '	SysUtils;');
	WriteLn(writeFile, 'var');
	WriteLn(writeFile, '	boxs: array [0..', HowManyInFile(fileName, '>'), '] of Byte;');
	WriteLn(writeFile, '	i : Integer;');
	WriteLn(writeFile, 'begin');
	WriteLn(writeFile, '	i:=0;');
	WriteLn(writeFile, '	for i:=0 to High(boxs) do');
	WriteLn(writeFile, '		boxs[i] := 0;');
	WriteLn(writeFile, '	i := 0;');

	AssignFile(readingFile, fileName);
	Reset(readingFile);
	while not eof(readingFile) do
	begin
		ReadLn(readingFile, readingLine);
		brainFuckCode := brainFuckCode + readingLine;
	end;
	DeleteGarbage(brainFuckCode, 0);
	ReadBrainFuckCode(brainFuckCode, writeFile);
	WriteLn(writeFile, 'end.');
	CloseFile(readingFile);
	CloseFile(writeFile);
	WriteLn('Read ', Length(brainFuckCode), ' Chars');
end;

function CheckInput(var fileName: UnicodeString): Boolean;
begin
	result := false;
	if ParamCount = 1 then
	begin
		fileName := ParamStr(1);
		if FileExists(fileName) then
		begin
			WriteLn('UnbrainFucking ', fileName);
			result := true;
		end
		else
			WriteLn(fileName, ' Not Found');
	end
	else
		WriteLn('Must Select Input File');
end;

procedure main();
var
	fileName : UnicodeString;

begin
	if CheckInput(fileName) then
		ReadFile(fileName);
end;

begin
	main();
end.
