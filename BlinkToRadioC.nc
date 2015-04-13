#include <Timer.h>
#include "BlinkToRadio.h"
 
module BlinkToRadioC {
	uses interface Boot;
	uses interface Leds;
	uses interface Timer<TMilli> as Timer0;
	uses interface Packet;
	uses interface AMPacket;
	uses interface AMSend;
	uses interface SplitControl as AMControl;
	uses interface Receive;
}	

implementation {
	
	bool busy = FALSE;
	message_t pkt;
	uint16_t counter = 0;
  
	event void Timer0.fired() {
		
		dbg("RadioCountToLedsC","Timer fired start\n");
		counter++;
		dbg("RadioCountToLedsC","Contador disparado\n");
		
		if (!busy) {
			BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)(call Packet.getPayload(&pkt, sizeof (BlinkToRadioMsg)));
			btrpkt->nodeid = TOS_NODE_ID;
			btrpkt->counter = counter;
			if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(BlinkToRadioMsg)) == SUCCESS) {
				busy = TRUE;
			}
		}
		dbg("RadioCountToLedsC","Timer fired end\n");
	}
	
	  
	event void AMSend.sendDone(message_t* msg, error_t error) {
		dbg("Boot", "Message sent.\n");
		if (&pkt == msg) {
			busy = FALSE;
		}
	}
	
	event void Boot.booted() {
		dbg("Boot,", "Application booted.\n");
		call AMControl.start();
		dbg("Boot", "AMControl started.\n");
	}


	event void AMControl.startDone(error_t err) {
		dbg("Boot", "Starting AMControl\n")
		if (err == SUCCESS) {
			call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
		}
		else {
			call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t err) {
	}
	
	event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
		dbg("RadioCountToLedsC", "Received packet of length %hhu.\n", len);
		if (len == sizeof(BlinkToRadioMsg)) {
			BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)payload;
			call Leds.set(btrpkt->counter);
		}
		return msg;
	}
}
