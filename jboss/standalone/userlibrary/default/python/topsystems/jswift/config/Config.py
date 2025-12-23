# package topsystems.jswift.config

from java.lang import String
from java.lang import Integer
from topsystems.jchannels import ChannelException

# Retorna los destinatarios de mail para cada una de las categorias posible del resultado del procesamiento de un mensanje swift
def getToMail(code, message):
	receivers = []
	if code == ChannelException.OK:
	    receivers.append("fpuigg@topsystems.com.uy")
	elif code == ChannelException.ERROR:
	    receivers.append("fpuigg@topsystems.com.uy")
	elif code == ChannelException.FATAL_ERROR:
	    receivers.append("fpuigg@topsystems.com.uy")
	elif code == ChannelException.ERROR_VALIDATE:
	    receivers.append("fpuigg@topsystems.com.uy")

	return receivers


# Retorna el sender de los mails para cada una de las categorias posible del resultado del procesamiento de un mensanje swift
def getFromMail(code, message):
	if code == ChannelException.OK:
	    return "fpuigg@topsystems.com.uy"
	elif code == ChannelException.ERROR:
	    return "fpuigg@topsystems.com.uy"
	elif code == ChannelException.FATAL_ERROR:
	    return "fpuigg@topsystems.com.uy"
	elif code == ChannelException.ERROR_VALIDATE:
	    return "fpuigg@topsystems.com.uy"
