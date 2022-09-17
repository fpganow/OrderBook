from typing import List


class SequencedUnitHeader:
    """
    Field          Offset   Length   Value/Type   Description
    Hdr Length       0        2        Binary     Length of entire block of messages.
                                                  Includes this and header and Hdr Count
                                                  messages to follow.
    Hdr Count        2        1        Binary     Number of messages to follow this header.
    Hdr Unit         3        1        Binary     Unit that applies to messages included
                                                  in this header.
    Hdr Sequence     4        4        Binary     Sequence of first message to follow this
                                                  header.
    """
    def __init__(self, hdr_sequence: int = 1, messages: List[None] = None):
        # Un-sequenced headers will have a 0 value for the sequence field
        # and potentially for the unit field.
        self._hdr_length = 0
        self._hdr_count = 0
        self._hdr_unit = 1
        self._hdr_sequence = hdr_sequence
        self._messages = messages


class Heartbeat:
    """
       A Sequenced Unit Header with a count field set to '0' will be used for
       heartbeat messages.
       During trading hours, heartbeat messages will be sent from the GRP and
       all multicast addresses if no data has been delivered within 1 second.
       Heartbeat messages never increments the sequence number.
       Heartbeats have a Hdr Sequence Value equal to the sequence of
       the next sequenced message.
    """
    def __init__(self):
        pass


class Time:
    """
        A Time message is immediately generated and sent when there is a PITCH
        event for a given clock second.

        Field          Offset   Length   Value/Type   Description
        Length           0        1        Binary     Length of this message including
                                                      this field
        Message Type     1        1         0x20      Time Message
        Time             2        4        Binary     Number of whole seconds from midnight
                                                      Eastern Time
    """
    def __init__(self):
        pass


class AddOrder:
    """
        Represents a newly accepted visible order on the Cboe book.

        Field          Offset   Length   Value/Type     Description
        Length           0        1        Binary       Length of this message including
                                                        this field
        Message Type     1        1         0x21        Add Order Message (long)
        Time Offset      2        4        Binary       Nanosecond offset from the last unit
                                                        timestamp
        Order Id         6        8        Binary       Day-specific identifier for this order
        Side Indicator  14        1      Alphanumeric   B = Buy Order
                                                        S = Sell Order
        Quantity        15        4        Binary       Number of shares/contracts being added
                                                        to the book
        Symbol          19        6       Printable     Symbol right padded with spaces
                                            ASCII
        Price           25        8        Binary       The limit order price
                                         Long Price
        Add Flags       33        1        BitField     Bit 0 - Display
                                                              0 = Order is not displayed
                                                              1 = Order is displayed
                                                        Bits 1-2 - Reserved
                                                        Bit3 - AON (Options only)
                                                        Bits 4-7 - Reserved

        Variations:
            Message Type = 0x22  Add Order Message (short)
              field     offset  length
              quantity    15      2
              symbol      17      6
              price       23      2
            Message Type = 0x2F  Add Order Message (expanded)
              field     offset  length
              quantity    15      2
              symbol      17      6
              price       23      2
    """
    def __init__(self,
                 side: str,
                 quantity: int,
                 symbol: str,
                 price: int):
        # Add Order (long) = 0x21
        # Add Order (short) = 0x22
        # Add Order (expanded) = 0x2F
        self._message_type = 0x21
        self._order_id = 100
        self._side = side
        self._quantity = quantity
        self._symbol = symbol
        self._price = price
