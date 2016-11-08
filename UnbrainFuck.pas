{
	Author: Paul Sarda
	Version 0.01
}
program PascalBrainFuck;

uses
  SysUtils, process;

type
	// used to store all options
 Options = record
  keepFile : Boolean;
  inputFileName : UnicodeString;
  outputFileName : UnicodeString;
  pascalOptions : String;
 end;

//
// Counts the Number of times a char is in a AnsiString
//
function OccurOfChar(const code: AnsiString; checkChar: Char): Integer;
var
	i: Integer;

begin
	result := 0;
	for i:=0 to Length(code) do
		if (code[i] = checkChar) then
			result += 1;
end;

//
// Counts How many Chars in a string in a row example: ++++ would be 4 so it would return 4
//
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


//
// interprets Brainfuck code an writes the approtie Pascal Code the writeFile
//
procedure ReadBrainFuckCode(var toRead: AnsiString; var writeFile : TextFile);
var
	i : Integer;

begin
	i := 0;
	while i <= Length(toRead) do
	begin
		case toRead[i] of
			'>'	:  WriteLn(writeFile,'	i += ', HowManyUntilNext(toRead, i, '>'), ';');
			'<'	: WriteLn(writeFile, '	i -= ', HowManyUntilNext(toRead, i, '<'), ';');
			'+'	: WriteLn(writeFile, '	boxs[i] += ', HowManyUntilNext(toRead, i, '+'), ';');
			'-'	: WriteLn(writeFile, '	boxs[i] -=' , HowManyUntilNext(toRead, i, '-'), ';');
			'.'	: WriteLn(writeFile, '	Write(Chr(boxs[i]));');
			','	: WriteLn(writeFile, '	boxs[i] := Byte(ReadKey);');
			'['	: begin
				 			WriteLn(writeFile, '	while(boxs[i] <> 0) do');
							WriteLn(writeFile, '	begin');
						end;
			']'	: WriteLn(writeFile, '	end;');
		end;
		i += 1;
	end;
end;

//
// Reads The brainfuck Code file copies and copies it into an AnsiString
// once Finshed Reading Converts Code Into Pascal Code and write that Into
// a new file
//
procedure ReadFile(var inputFileName, outputFileName: UnicodeString);
var
	readingLine, brainFuckCode: AnsiString;
	readingFile : TextFile;
	writeFile : TextFile;

begin
  WriteLn('UnbrainFucking ', inputFileName);
	AssignFile(readingFile, inputFileName);
	Reset(readingFile);
	while not eof(readingFile) do
	begin
		ReadLn(readingFile, readingLine);
		brainFuckCode := brainFuckCode + readingLine;
	end;
  CloseFile(readingFile);
  WriteLn('Creating ', outputFileName);
  AssignFile(writeFile, outputFileName);
	Rewrite(writeFile);
	WriteLn('Converting ', brainFuckCode, 'Into Pascal');
	// Pascal File
  WriteLn(writeFile, 'program test;');
	WriteLn(writeFile, 'uses');
	WriteLn(writeFile, '	SysUtils, Crt;');
	WriteLn(writeFile, 'var');
	WriteLn(writeFile, '	boxs: array [0..', OccurOfChar(brainFuckCode, '>') - OccurOfChar(brainFuckCode, '<') + 1, '] of Byte;');
	WriteLn(writeFile, '	i : Integer;');
	WriteLn(writeFile, 'begin');
	WriteLn(writeFile, '	i:=0;');
	WriteLn(writeFile, '	for i:=0 to High(boxs) do');
	WriteLn(writeFile, '		boxs[i] := 0;');
	WriteLn(writeFile, '	i := 0;');
	ReadBrainFuckCode(brainFuckCode, writeFile);
	WriteLn(writeFile, 'end.');
	// Pascal File
	CloseFile(writeFile);
	WriteLn('Read ', Length(brainFuckCode), ' Chars');
end;

//
// interprets parameters passed through the command line
//
function CheckInput(var compilerOptions: Options): Boolean;
var
  idx: Byte;

begin
  idx := 1;
	result := false;
	if ParamCount >= 1 then
	begin
    if ParamStr(idx) = '-k' then
    begin
      compilerOptions.keepFile := true;
      idx += 1;
    end
    else
      compilerOptions.keepFile := false;
		compilerOptions.inputFileName := ParamStr(idx);
    idx += 1;
		if FileExists(compilerOptions.inputFileName) then
		begin
			WriteLn('Selected File ', compilerOptions.inputFileName);
      if ParamStr(idx) = '-na'  then
      begin
        idx += 1;
        compilerOptions.outputFileName := ParamStr(idx);
      end
      else
        WriteLn(Pos('.', compilerOptions.inputFileName));
        compilerOptions.outputFileName := Copy(compilerOptions.inputFileName, 0, Pos('.', compilerOptions.inputFileName)) + 'pas';
      if (compilerOptions.outputFileName <> compilerOptions.inputFileName) then
        result := true
      else
        WriteLn('Input Name Cannot be the same as Output Name');
		end
    else
			WriteLn(compilerOptions.inputFileName, ' Not Found');
	end
	else
		WriteLn('Must Select Input File');
end;

//
// Compiles the genrated pascal code
//
procedure CompilePascalCode(const compilerOptions: Options);
var
  terminalOut: AnsiString;

begin
  WriteLn('Compiling Pascal Code from ', compilerOptions.outputFileName);
  {$IFDEF WINDOWS}
		RunCommand('c:\windows\system32\cmd.exe', ['/c', 'fpc -S2 ', compilerOptions.outputFileName], terminalOut);
	{$ENDIF}
  {$IFDEF UNIX}
    RunCommand('/bin/bash', ['-c', 'fpc -S2 ', compilerOptions.outputFileName], terminalOut);
  {$ENDIF}
  WriteLn(terminalOut);
end;

procedure main();
var
	compilerOptions : Options;

begin
	if CheckInput(compilerOptions) then
		ReadFile(compilerOptions.inputFileName, compilerOptions.outputFileName);

  if FileExists(compilerOptions.outputFileName) then
    CompilePascalCode(compilerOptions);
  if (compilerOptions.keepFile = false) then
  begin
    DeleteFile(compilerOptions.outputFileName);
    DeleteFile(Copy(compilerOptions.inputFileName, 0, Pos('.', compilerOptions.inputFileName)) + 'o');
  end;
end;

begin
	main();
end.
