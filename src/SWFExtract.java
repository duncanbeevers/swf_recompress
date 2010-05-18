import java.io.*;
import java.util.zip.*;
public class SWFExtract{
	public static void main(String[]args)throws Exception{
		String name = args[0];
		String dataOutputFileName = args[1];
		String infoOutputFileName = args[2];
		File file=new File(name);
		DataInputStream in=new DataInputStream(new FileInputStream(file));

		boolean compressed=true;
		byte first=in.readByte();
		if(first==0x46) //'F'
			compressed=false;
		else if(first!=0x43) //'C'
			noSWF();
		if(in.readByte()!=0x57)//'W'
			noSWF();
		if(in.readByte()!=0x53)//'S'
			noSWF();
		byte version=in.readByte();

		in.skipBytes(4);//skip length of file field

		DataOutputStream out=new DataOutputStream(new FileOutputStream(dataOutputFileName));
		InputStream in2;
		if(compressed)
			in2=new InflaterInputStream(in);
		else
			in2=new DataInputStream(in);
		byte[]data=new byte[4096];
		int r;
		Adler32 a32=new Adler32();
		while((r=in2.read(data))!=-1){
			out.write(data,0,r);
			a32.update(data,0,r);
		}
		in2.close();
		out.flush();
		out.close();

		DataOutputStream iout=new DataOutputStream(new FileOutputStream(infoOutputFileName));
		iout.writeUTF(name.substring(0,name.lastIndexOf('.')));
		iout.write(version);
		iout.writeInt((int)a32.getValue());
		iout.writeLong(file.length());
		iout.flush();
		iout.close();
	}
	private static void noSWF(){
		System.err.println("not an SWF file");
		System.exit(1);
	}
}
