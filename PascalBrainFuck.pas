{
	Author: Paul Sarda
	Version 0.02
}
program PascalBrainBlank;

uses
  SysUtils, process;

type
	Lang = (LaPascal, LaC);
	// used to store all options
 Options = record
 	comLang : Lang;
	comOpt : UniCodeString;
  keepFile : Boolean;
  inputFileName : UniCodeString;
  outFileName : UniCodeString;
	brainFuckCode: AnsiString
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
// Returns a string with the num of char given eg 4, #9 returns 4 tabs
//
function RetNumOfChar(num: Integer; reChar: Char): String;
var
	i : Integer;

begin
	result := '';
	i:= 0;
	while (num > i) do
	begin
		result := result + reChar;
		i += 1;
	end;
end;

//
// Counts How many Chars in a string in a row example: ++++> would be 4 so it would return 4
//
function VarHowManyInRow(var toRead: AnsiString; var idx: Integer; toCheck: AnsiChar): Integer;
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
// interprets BrainBlank code an writes the approtie Pascal Code the writeFile
//
procedure ConvertBrainFuckPascal(var code: AnsiString; var writeFile : TextFile);
var
	i, tabs : Integer;

begin
	i := 0;
	//Used to Track how many tabs are needed in the write file
	tabs := 1;
	while (i <= Length(code)) do
	begin
		case code[i] of
			'>'	:	WriteLn(writeFile, RetNumOfChar(tabs, #9), 'i += ', VarHowManyInRow(code, i, '>'), ';');
			'<'	: WriteLn(writeFile, RetNumOfChar(tabs, #9), 'i -= ', VarHowManyInRow(code, i, '<'), ';');
			'+'	: WriteLn(writeFile, RetNumOfChar(tabs, #9), 'boxs[i] += ', VarHowManyInRow(code, i, '+'), ';');
			'-'	: WriteLn(writeFile, RetNumOfChar(tabs, #9), 'boxs[i] -= ' , VarHowManyInRow(code, i, '-'), ';');
			'.'	: WriteLn(writeFile, RetNumOfChar(tabs, #9), 'Write(Chr(boxs[i]));');
			','	: WriteLn(writeFile, RetNumOfChar(tabs, #9), 'boxs[i] := Byte(ReadKey);');
			'['	: begin
							WriteLn(writeFile, RetNumOfChar(tabs, #9), 'while(boxs[i] <> 0) do');
							WriteLn(writeFile, RetNumOfChar(tabs, #9), 'begin');
							tabs += 1;
						end;
			']'	: begin
							tabs -= 1;
							WriteLn(writeFile, RetNumOfChar(tabs, #9), 'end;');
						end;
		end;
		i += 1;
	end;
end;

procedure GenratePascalFile(const outFileName: UniCodeString; var brainFuckCode: AnsiString);
var
	writeFile : TextFile;

begin
	WriteLn('Creating ', outFileName);
  AssignFile(writeFile, outFileName);
	Rewrite(writeFile);
	WriteLn('Converting ', brainFuckCode, 'Into Pascal');
	// Start of Out Pascal File
  WriteLn(writeFile, 'program test;');
	WriteLn(writeFile, 'uses');
	WriteLn(writeFile, '	SysUtils, Crt;');
	WriteLn(writeFile, 'var');
	// Sets Size of array to the amount of right shifts to create the smallest Possbile Array
	WriteLn(writeFile, '	boxs: array [0..', OccurOfChar(brainFuckCode, '>') - OccurOfChar(brainFuckCode, '<') + 1, '] of Byte;');
	WriteLn(writeFile, '	i : Integer;');
	WriteLn(writeFile, 'begin');
	WriteLn(writeFile, '	i:=0;');
	WriteLn(writeFile, '	for i:=0 to High(boxs) do');
	WriteLn(writeFile, '		boxs[i] := 0;');
	WriteLn(writeFile, '	i := 0;');
	ConvertBrainFuckPascal(brainFuckCode, writeFile);
	WriteLn(writeFile, 'end.');
	// end of Pascal File
	CloseFile(writeFile);
	WriteLn('Read ', Length(brainFuckCode), ' Chars');
end;

procedure ConvertBrainFuckC(var code: AnsiString; var writeFile : TextFile);
var
	i, tabs : Integer;

begin
	i := 0;
	//Used to Track how many tabs are needed in the write file
	tabs := 1;
	while (i <= Length(code)) do
	begin
		case code[i] of
			'>'	: WriteLn(writeFile, RetNumOfChar(tabs, #9), 'i += ', VarHowManyInRow(code, i, '>'), ';');
			'<'	: WriteLn(writeFile, RetNumOfChar(tabs, #9), 'i -= ', VarHowManyInRow(code, i, '<'), ';');
			'+'	: WriteLn(writeFile, RetNumOfChar(tabs, #9), 'boxs[i] += ', VarHowManyInRow(code, i, '+'), ';');
			'-'	: WriteLn(writeFile, RetNumOfChar(tabs, #9), 'boxs[i] -= ' , VarHowManyInRow(code, i, '-'), ';');
			'.'	: WriteLn(writeFile, RetNumOfChar(tabs, #9), 'printf("%c", boxs[i]);');
			','	: WriteLn(writeFile, RetNumOfChar(tabs, #9), 'boxs[i] = getchar();');
			'['	: begin
				 			WriteLn(writeFile, RetNumOfChar(tabs, #9), 'while(boxs[i]){');
							tabs += 1;
						end;
			']'	: begin
							tabs -= 1;
							WriteLn(writeFile, RetNumOfChar(tabs, #9), '}');
						end;
		end;
		i += 1;
	end;
end;

procedure GenrateCFile(var outFileName: UniCodeString; var brainFuckCode: AnsiString);
var
	writeFile : TextFile;

begin
	WriteLn('Creating ', outFileName);
  AssignFile(writeFile, outFileName);
	Rewrite(writeFile);
	WriteLn('Converting ', brainFuckCode, 'Into C');
	// Start of Out C File
  WriteLn(writeFile, '#include<stdio.h>');
	WriteLn(writeFile, 'int main(void){');
	WriteLn(writeFile, #9'char boxs [', OccurOfChar(brainFuckCode, '>'),'] = {0};');
	WriteLn(writeFile, #9'int i = 0;');
	ConvertBrainFuckC(brainFuckCode, writeFile);
	WriteLn(writeFile, #9'return 0;');
	WriteLn(writeFile, '}');
	// end of C File
	CloseFile(writeFile);
	WriteLn('Read ', Length(brainFuckCode), ' Chars');
end;

//
// Deleting From AnsiString Is really Strange So this is a garbage Soultion
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
function ReadBrainfuck(var inputFileName: UniCodeString): AnsiString;
var
	readingLine : AnsiString;
	readingFile : TextFile;

begin
  WriteLn('UnBrainBlanking ', inputFileName);
	AssignFile(readingFile, inputFileName);
	Reset(readingFile);
	while not eof(readingFile) do
	begin
		ReadLn(readingFile, readingLine);
		result := result + readingLine;
	end;
	result := RemoveGarbage(result);
  CloseFile(readingFile);
end;

function StringToLang(toCheck: String): Lang;
begin
	result := LaPascal;
	case toCheck of
		'p' : result := LaPascal;
		'c' : result := LaC;
	end;
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
		compOpt.keepFile := false;
		compOpt.comLang := LaPascal;
		compOpt.comOpt := '';
		//Switch section
		while (ParamCount - idx >= 1) do
		begin
			if ParamStr(idx) = '-k' then
	    begin
	      compOpt.keepFile := true;
	    end;
			//Checks Witch comLang to output
			if ParamStr(idx) = '-l' then
			begin
				idx += 1;
				compOpt.comLang := StringToLang(ParamStr(idx));
			end;
			if ParamStr(idx) = '-na'  then
      begin
        idx += 1;
        compOpt.outFileName := ParamStr(idx);
      end;
			if ParamStr(idx) = '-c'  then
      begin
        idx += 1;
        compOpt.comOpt := ParamStr(idx);
      end;
			idx += 1;
		end;
		compOpt.inputFileName := ParamStr(idx);
    idx += 1;
		if FileExists(compOpt.inputFileName) then
		begin
			WriteLn('Selected File ', compOpt.inputFileName);
      if (compOpt.outFileName = '') then
			begin
				// Checks if there is an ./ at the start of the name for the file then deletes it
				if (Pos('.', compOpt.inputFileName) = 1) then
					Delete(compOpt.inputFileName, 1, 2);
				//Copies the name part of the file then adds the .pas
      	compOpt.outFileName := Copy(compOpt.inputFileName, 0, Pos('.', compOpt.inputFileName)-1);
			end;
			case compOpt.comLang of
				LaPascal 	: compOpt.outFileName := compOpt.outFileName + '.pas';
				LaC 			: compOpt.outFileName := compOpt.outFileName + '.c';
			end;
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
function CompileOutFile(const compOpt: Options): Boolean;
var
  terminalOut, compileComand: AnsiString;

begin
	result := false;
	case compOpt.comLang of
		LaPascal 	: compileComand := '/c ' + 'fpc -S2 ' + compOpt.comOpt + ' ' + compOpt.outFileName;
		LaC				: compileComand := '/c ' + 'gcc -o ' + Copy(compOpt.inputFileName, 0, Pos('.', compOpt.inputFileName)-1) + ' ' + compOpt.outFileName;
	end;
	WriteLn('Running: ', compileComand);
  {$IFDEF WINDOWS}
		RunCommand('c:\windows\system32\cmd.exe', [compileComand], terminalOut);
	{$ENDIF}
  {$IFDEF UNIX}
    RunCommand('/bin/bash', [compileComand], terminalOut);
  {$ENDIF}
	result := FileExists(Copy(compOpt.inputFileName, 0, Pos('.', compOpt.inputFileName))+ 'exe');
  WriteLn(terminalOut);
end;

procedure main();
var
	compOpt : Options;

begin
	if CheckInput(compOpt) then
	begin
		compOpt.brainFuckCode := ReadBrainfuck(compOpt.inputFileName);
		case compOpt.comLang of
			LaPascal	: GenratePascalFile(compOpt.outFileName, compOpt.brainFuckCode);
			LaC 			: GenrateCFile(compOpt.outFileName, compOpt.brainFuckCode);
		end;
	end;

  if FileExists(compOpt.outFileName) then
		if CompileOutFile(compOpt) then
		begin
			if (compOpt.keepFile = false) then
		  begin
		    DeleteFile(compOpt.outFileName);
		    DeleteFile(Copy(compOpt.inputFileName, 0, Pos('.', compOpt.inputFileName)) + 'o');
		  end;
		end;
end;

begin
	main();
end.
