import argparse

def pad32(x):
	e = ''
	for i in range(0,32):
		e = e+"0"
	x = x.split("0b")[-1].strip("L")
	if x=='0':
		return e
	return (e+'0')[:-len(x)-1]+x

def parse(line):
	opcodeHash = {"001000":"ADDI",
					"001100":"ANDI",
					"001111":"LUI",
					"001101":"ORI",
					"001010":"SLTI",
					"000100":"BEQ",
					"010101":"BNE",
					"100011":"LW",
					"101011":"SW",
					"000000":"RTYPE",
					"000010":"J",
					}

	typesOfR = {"100000":"ADD",
				"100010":"SUB",
				"100100":"AND",
				"100101":"OR",
				"100110":"XOR",
				"100111":"NOR",
				"101010":"SLT",
				}
	line = pad32(bin(int(line,16)))
	outputLine = opcodeHash[line[0:6]]
	if outputLine=="RTYPE":
		outputLine=typesOfR[line[26:32]]

	if outputLine in ('ADD','SUB','AND','OR','XOR','NOR','SLT'):
		completeOutput = outputLine+" $"+str(int(line[16:21],2))+" $"+str(int(line[6:11],2))+" $"+str(int(line[11:16],2))
		return completeOutput
	elif outputLine in ('ADDI','ANDI','ORI','SLTI'):
		completeOutput = outputLine+" $"+str(int(line[11:16],2))+" $"+str(int(line[6:11],2))+" "+str(int(line[16:32],2))
		return completeOutput
	elif outputLine == 'LUI':
		completeOutput = outputLine+" $"+str(int(line[11:16],2))+" "+str(int(line[16:32],2))
		return completeOutput
	elif outputLine in ('LW','SW'):
		completeOutput = outputLine+" $"+str(int(line[11:16],2))+" "+str(int(line[16:32],2))+"($"+str(int(line[6:11],2))+")"
		return completeOutput
	elif outputLine in ('BNE','BEQ'):
		completeOutput = outputLine+" $"+str(int(line[6:11],2))+" $"+str(int(line[11:16],2))+" "+str(int(line[16:32],2))
		return completeOutput
	elif outputLine in ('J'):
		return outputLine+" "+str(int(line[16:32],2))


def disassemble(source,target):
	disassembledString=''
	sourceFile = open(source,"r")
	destFile = open(target,"w")

	line = sourceFile.readline()
	while line!='':
		if 'ffffffff' not in line.lower():
			disassembledString=disassembledString+parse(line)+"\n"
		
		line = sourceFile.readline()

	destFile.write(disassembledString)
	sourceFile.close()
	destFile.close()

if __name__=="__main__":
	parser = argparse.ArgumentParser()
	parser.add_argument("input",help="Filename of instmem to translate")
	args = parser.parse_args()
	i = args.input

	try:
		disassemble(i,"translated_"+i)
	except:
		print "File Error"