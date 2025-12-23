# package topsystems.jswift.channel

from java.lang import String
from java.util import ArrayList
from topsystems.jswift.wrappers import SwiftBlockInfoWrapper
from topsystems.jswift.wrappers import SwiftMessageBasicWrapper

def getOutputChannelName(swiftMessage):
	
	outputNames = ArrayList()
	
	messageNumber = swiftMessage.getMessageNumber()
	
	outputNames.add("SWIFTOUT")
	
	return outputNames
	

