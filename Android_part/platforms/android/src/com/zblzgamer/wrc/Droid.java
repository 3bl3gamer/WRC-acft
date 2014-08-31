package com.zblzgamer.wrc;

import android.webkit.JavascriptInterface;
import android.webkit.WebView;
import android.os.AsyncTask;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.UnknownHostException;

public class Droid
{
	private WebView webView;
	private DatagramSocket sock = null;
	
	public Droid(final WebView webView)
	{
		this.webView = webView;
	}
	
	private void execInWebView(final String code)
	{
		webView.post(new Runnable() {
			@Override
			public void run() {
				webView.loadUrl("javascript:"+code);
			}
		});
	}
	
	@JavascriptInterface
	public String _UDP_bind(int port)
	{
		try {
			if (port > 0) {
				sock = new DatagramSocket(port);
			} else {
				sock = new DatagramSocket();
			}
		} catch(Exception e) {//IOException
			return "Failed to create and bind socket: "+e.toString();
		}
		return null;
	}
	
	@JavascriptInterface
	public String _UDP_startReceiver(final String onReceiveFuncName, final String onErrorFuncName)
	{
		if (this.sock == null) return "Socket not created yet";
		final DatagramSocket sock = this.sock;
		
		new Thread()
		{
			@Override
			public void run()
			{
				byte[] rbuf = new byte[4096];
				DatagramPacket rpack = new DatagramPacket(rbuf, rbuf.length);
				
				while(true) {
					try {
						sock.receive(rpack);
						String data = new String(rbuf, 0, rpack.getLength());
						String addr = new String(rpack.getAddress().getAddress());
						int port = rpack.getPort();
						execInWebView(onReceiveFuncName+"('"+addr+"', "+port+", '"+data+"')");
					} catch(IOException e) {
						execInWebView(onErrorFuncName+"('Failed to receive from socket')");
					}
				}
			}
		}.start();
		
		return null;
	}
	
	@JavascriptInterface
	public String _UDP_send(int addr, int port, String data)
	{
		byte[] baddr = {(byte)((addr>>24)&0xFF), (byte)((addr>>16)&0xFF), (byte)((addr>>8)&0xFF), (byte)(addr&0xFF)};
		InetAddress iaddr;
		try {
			iaddr = InetAddress.getByAddress(baddr);
		} catch(UnknownHostException e) {
			String msg = "Wrong address: ";
			for (int i=0; i<baddr.length-1; i++) msg += baddr[i]+".";
			msg += baddr[baddr.length-1];
			msg += " ("+baddr.length+")";
			return msg;
		}
		DatagramPacket spack = new DatagramPacket(data.getBytes(), data.length(), iaddr, port);
		//spack.setBroadcast(true);
		try {
			sock.send(spack);
		} catch(IOException e) {
			return "Failed to send to socket: "+e.toString();
		}
		
		return null;
	}
	
	@JavascriptInterface
	public String test()
	{
		webView.post(new Runnable() {
			//@override
			public void run() {
				byte[] buf = {48,49,50,51};
				try {
					webView.loadUrl("javascript:testFunc('"+new String(InetAddress.getByAddress(buf).getAddress())+"')");//.getHostAddress()
				} catch (UnknownHostException e) {}
			}
		});
		return "test string";
	}
}
