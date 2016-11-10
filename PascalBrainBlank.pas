{
	I apologise for the language bellow but it is the name of the programming language.
	Brain(Blank) is a programming language created in 1992 by Urban Muller https://en.wikipedia.org/wiki/BrainBlank .
	The Programming Language Interested Me. so I created this interpreter which reads BrainBlank Code and Translates it into pascal then compiles said pascal code.
	I already had an D/HD Custom program and I made this Over the course of the final week so this IS NOT MY CUSTOM PROGRAM but it is Additional work I Completed. you can find the complete Public GitHub Repo here https://github.com/sardap/PascalBrainBlank (I am the only contributor) on the Repo you can find Brain(Blank) some BrainBlank code written by me and a readme.
	Author: Paul Sarda
	Version 0.02
}
program PascalBrainBlank;

uses
  SysUtils, process;

type
	// used to store all options
 Options = record
  keepFile : Boolean;
  inputFileName : UnicodeString;
  outFileName : UnicodeString;
  pasOpt : UnicodeString;
	run : Boolean;
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
// Counts How many Chars in a string in a row example: ++++> would be 4 so it would return 4
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
// Returns a string with the num of char given eg 4, #9 returns 4 tabs
//
function RetNumOfChar(num: Integer; reChar: Char): String;
var
	i : Integer;

begin
	result := '';
	i:= 0;
	while (num >= i) do
	begin
		result := result + reChar;
		i += 1;
	end;
end;

//
// interprets BrainBlank code an writes the approtie Pascal Code the writeFile
//
procedure ReadBrainBlankCode(var toRead: AnsiString; var writeFile : TextFile);
var
	i, tabs : Integer;

begin
	i := 0;
	//Used to Track how many tabs are needed in the write file
	tabs := 1;
	while (i <= Length(toRead)) do
	begin
		case toRead[i] of
			'>'	: WriteLn(writeFile, RetNumOfChar(tabs, #9), 'i += ', HowManyUntilNext(toRead, i, '>'), ';');
			'<'	: WriteLn(writeFile, RetNumOfChar(tabs, #9), 'i -= ', HowManyUntilNext(toRead, i, '<'), ';');
			'+'	: WriteLn(writeFile, RetNumOfChar(tabs, #9), 'boxs[i] += ', HowManyUntilNext(toRead, i, '+'), ';');
			'-'	: WriteLn(writeFile, RetNumOfChar(tabs, #9), 'boxs[i] -=' , HowManyUntilNext(toRead, i, '-'), ';');
			'.'	: WriteLn(writeFile, RetNumOfChar(tabs, #9), 'Write(Chr(boxs[i]));');
			','	: WriteLn(writeFile, RetNumOfChar(tabs, #9), 'boxs[i] := Byte(ReadKey);');
			'['	: begin
				 			WriteLn(writeFile, RetNumOfChar(tabs, #9), 'while(boxs[i] <> 0) do');
							WriteLn(writeFile, RetNumOfChar(tabs, #9), 'begin');
							tabs += 1;
						end;
			']'	: begin
							WriteLn(writeFile, RetNumOfChar(tabs, #9), 'end;');
							tabs -= 1;
						end;
		end;
		i += 1;
	end;
end;
//
// Deleting From AnsiStrings Is really Strange So this is a garbage Soultion
//
function RemoveGarbage(const code: AnsiString): AnsiString;
var
	i : Integer;

begin
	// There must be a better way
	for i:=0 to Length(code) do
		if ((code[i] = '>') or
				(code[i] = '<') or
				(code[i] = '+') or
				(code[i] = '-') or
				(code[i] = '.') or
				(code[i] = ',') or
				(code[i] = '[') or
				(code[i] = ']')
				) then
			result := result + code[i];
end;
// Reads The BrainBlank Code file copies and copies it into an AnsiString
// once Finshed Reading Converts Code Into Pascal Code and write that Into
// a new file
procedure ReadFile(var inputFileName, outFileName: UnicodeString);
var
	readingLine, BrainBlankCode: AnsiString;
	readingFile : TextFile;
	writeFile : TextFile;

begin
  WriteLn('UnBrainBlanking ', inputFileName);
	AssignFile(readingFile, inputFileName);
	Reset(readingFile);
	while not eof(readingFile) do
	begin
		ReadLn(readingFile, readingLine);
		BrainBlankCode := BrainBlankCode + readingLine;
	end;
	BrainBlankCode := RemoveGarbage(BrainBlankCode);
  CloseFile(readingFile);
  WriteLn('Creating ', outFileName);
  AssignFile(writeFile, outFileName);
	Rewrite(writeFile);
	WriteLn('Converting ', BrainBlankCode, 'Into Pascal');
	// Start of Out Pascal File
  WriteLn(writeFile, 'program test;');
	WriteLn(writeFile, 'uses');
	WriteLn(writeFile, '	SysUtils, Crt;');
	WriteLn(writeFile, 'var');
	// Sets Size of array to the amount of right shifts to create the smallest Possbile Array
	WriteLn(writeFile, '	boxs: array [0..', OccurOfChar(BrainBlankCode, '>') - OccurOfChar(BrainBlankCode, '<') + 1, '] of Byte;');
	WriteLn(writeFile, '	i : Integer;');
	WriteLn(writeFile, 'begin');
	WriteLn(writeFile, '	i:=0;');
	WriteLn(writeFile, '	for i:=0 to High(boxs) do');
	WriteLn(writeFile, '		boxs[i] := 0;');
	WriteLn(writeFile, '	i := 0;');
	ReadBrainBlankCode(BrainBlankCode, writeFile);
	WriteLn(writeFile, 'end.');
	// end of Pascal File
	CloseFile(writeFile);
	WriteLn('Read ', Length(BrainBlankCode), ' Chars');
end;

//
// interprets parameters passed through the command line
//
function CheckInput(var compOpt: Options): Boolean;
var
  idx: Byte;

begin
  idx := 1;
	result := false;
	if ParamCount >= 1 then
	begin
    if ParamStr(idx) = '-k' then
    begin
      compOpt.keepFile := true;
      idx += 1;
    end
    else
      compOpt.keepFile := false;
		if ParamStr(idx) = '-r' then
		begin
			compOpt.run := true;
			idx += 1;
		end
		else
			compOpt.run := false;
		compOpt.inputFileName := ParamStr(idx);
    idx += 1;
		if FileExists(compOpt.inputFileName) then
		begin
			WriteLn('Selected File ', compOpt.inputFileName);
      if ParamStr(idx) = '-na'  then
      begin
        idx += 1;
        compOpt.outFileName := ParamStr(idx);
      end
      else
				// Checks if there is an ./ at the start of the name for the file then deletes it
				if (Pos('.', compOpt.inputFileName) = 1) then
					Delete(compOpt.inputFileName, 1, 2);
				//Copies the name part of the file then adds the .pas
        compOpt.outFileName := Copy(compOpt.inputFileName, 0, Pos('.', compOpt.inputFileName)) + 'pas';
      if (compOpt.outFileName <> compOpt.inputFileName) then
        result := true
      else
        WriteLn('Input Name Cannot be the same as Output Name');
		end
    else
			WriteLn(compOpt.inputFileName, ' Not Found');
	end
	else
		WriteLn('Must Select Input File');
end;

//
// Compiles the genrated pascal code
//
procedure CompilePascalCode(const compOpt: Options);
var
  terminalOut, compileComand: AnsiString;

begin
	compileComand := '/c ' + 'fpc -S2 ' + compOpt.pasOpt + compOpt.outFileName;
  WriteLn('Compiling Pascal Code from ', compOpt.outFileName);
	WriteLn('Running: ', compileComand);
  {$IFDEF WINDOWS}
		RunCommand('c:\windows\system32\cmd.exe', [compileComand], terminalOut);
	{$ENDIF}
  {$IFDEF UNIX}
    RunCommand('/bin/bash', [compileComand], terminalOut);
  {$ENDIF}
  WriteLn(terminalOut);
end;
//
// This is broken
//
procedure RunProgram(const compOpt: Options);
var
	terminalOut, toExcute: AnsiString;

begin
	toExcute := '-c' + '.\' + Copy(compOpt.outFileName, 0, Pos('.', compOpt.inputFileName));
	{$IFDEF WINDOWS}
	 	toExcute := toExcute + 'exe';
		WriteLn('Excuting ', toExcute);
		RunCommand('c:\windows\system32\cmd.exe', [toExcute], terminalOut);
	{$ENDIF}
  {$IFDEF UNIX}
    RunCommand('/bin/bash', [toExcute], terminalOut);
  {$ENDIF}
	WriteLn(terminalOut);
end;

procedure main();
var
	compOpt : Options;

begin
	if CheckInput(compOpt) then
		ReadFile(compOpt.inputFileName, compOpt.outFileName);

  if FileExists(compOpt.outFileName) then
    CompilePascalCode(compOpt);
  if (compOpt.keepFile = false) then
  begin
    DeleteFile(compOpt.outFileName);
    DeleteFile(Copy(compOpt.inputFileName, 0, Pos('.', compOpt.inputFileName)) + 'o');
  end;
	if (compOpt.run = true) then
		RunProgram(compOpt);
end;

begin
	main();
end.
