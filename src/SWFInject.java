import java.io.*;
import java.util.zip.*;
import java.text.*;
public class SWFInject{
	public static void main(String[]args)throws Exception{
		String zipInputFileName = args[0];
		String infoInputFileName = args[1];
		String outputFileName = args[2];
		
		DataInputStream iin=new DataInputStream(new FileInputStream(infoInputFileName));
		byte version=iin.readByte();
		int a32=iin.readInt();
		long oldLength=iin.readLong();
		iin.close();

		File outFile=new File(outputFileName);
		DataInputStream in=new DataInputStream(new FileInputStream(zipInputFileName));
		DataOutputStream out=new DataOutputStream(new FileOutputStream(outFile));

		in.skipBytes(4+2+2+2+2+2+4);

		int compressedSize=Integer.reverseBytes(in.readInt());
		int uncompressedSize=Integer.reverseBytes(in.readInt());

		in.skipBytes(2+2+8);

		byte[]data=new byte[compressedSize];
		in.readFully(data);
		in.close();

		out.write(0x43);//'C'
		out.write(0x57);//'W'
		out.write(0x53);//'S'
		out.write(version<6?6:version);
		int newSize=1+1+1+1+4+1+1+uncompressedSize+4;
		out.writeInt(Integer.reverseBytes(newSize));

		out.write(0x78);
		out.write(0xDA);
		out.write(data,0,data.length);
		out.writeInt(a32);
		out.flush();
		out.close();

		DecimalFormat byteFormat=new DecimalFormat("###,###");
		long newLength=outFile.length();
		System.out.printf("old Length: %10s\n",byteFormat.format(oldLength));
		System.out.printf("new Length: %10s\n",byteFormat.format(newLength));
		System.out.printf("saved     : %10s (%.2f%%)\n",byteFormat.format(oldLength-newLength),100-(100.0/oldLength*newLength));
	}
}