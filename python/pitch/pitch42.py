import collections
from datetime import datetime
from typing import Any, ByteString, List, OrderedDict
from enum import Enum

import logging

logger = logging.getLogger(__name__)


class FieldName(Enum):
    HdrLength = 'Hdr Length'
    HdrCount = 'Hdr Count'
    HdrUnit = 'Hdr Unit'
    HdrSequence = 'Hdr Sequence'

    AddFlags = 'Flags'
    Length = 'Length'
    ExecutedQuantity = 'Executed Quantity'
    ExecutionId = 'Execution Id'
    MessageType = 'Message Type'
    OrderId = 'Order Id'
    Price = 'Price'
    Quantity = 'Quantity'
    SideIndicator = 'Side Indicator'
    Symbol = 'Symbol'
    Time = 'Time'
    TimeOffset = 'Time Offset'


class FieldType(Enum):
    Alphanumeric = 0
    Binary = 1
    BinaryLongPrice = 2
    BinaryShortPrice = 3
    BitField = 4
    PrintableAscii = 5
    Value = 6


class FieldSpec:
    def __init__(self,
                 field_name: FieldName,
                 offset: int,
                 length: int,
                 field_type: FieldType,
                 value: Any = None):
        self._name = field_name
        self._offset = offset
        self._length = length
        self._field_type = field_type
        self._value = value

    def offset(self, offset: int = None) -> int:
        if offset is not None:
            self._offset = offset
        return self._offset

    def length(self, length: int = None) -> int:
        if length is not None:
            self._length = length
        return self._length

    def value(self, value: Any = None) -> Any:
        if value is not None:
            self._value = value
        return self._value

    def get_bytes(self) -> ByteString:
        if self._field_type == FieldType.Alphanumeric:
            return self._value.encode()
        elif self._field_type == FieldType.Binary:
            if type(self._value) is str:
                return self._value.encode()
            return self._value.to_bytes(self._length, byteorder='little')
        elif self._field_type == FieldType.BinaryLongPrice:
            tmp_val = int(self._value * 10_000)
            return tmp_val.to_bytes(self._length, byteorder='little')
        elif self._field_type == FieldType.BitField:
            return self._value.to_bytes(self._length, byteorder='little')
        elif self._field_type == FieldType.PrintableAscii:
            tmp_val = self._value + (6 - len(self._value) ) * ' '
            return tmp_val.encode()
        elif self._field_type == FieldType.Value:
            return self._value.to_bytes(self._length, byteorder='little')
        return bytearray([])


class MessageBase:
    def __init__(self):
        pass

    def get_bytes(self):
        final_msg = bytearray()

        for field_name, field_spec in self._field_specs.items():
            logger.debug(f'{field_name}')

            tmp_val = field_spec.get_bytes()
            tmp_val_str = [f'0x{format(x, "02x")}' for x in tmp_val]
            logger.debug(f'\tAppending: {list(tmp_val_str)}')

            final_msg.extend(tmp_val)
        return final_msg


class SequencedUnitHeader(MessageBase):
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
    def __init__(self,
                 hdr_count: int = 0,
                 hdr_unit: int = 1,
                 hdr_sequence: int = 1):

        self._field_specs: OrderedDict[FieldName, FieldSpec] = collections.OrderedDict()
        self._field_specs[FieldName.HdrLength] = FieldSpec(field_name=FieldName.HdrLength,
                                                           offset=0, length=2,
                                                           field_type=FieldType.Binary)
        self._field_specs[FieldName.HdrCount] = FieldSpec(field_name=FieldName.HdrCount,
                                                           offset=2, length=1,
                                                           field_type=FieldType.Binary)
        self._field_specs[FieldName.HdrUnit] = FieldSpec(field_name=FieldName.HdrUnit,
                                                          offset=3, length=1,
                                                          field_type=FieldType.Binary)
        self._field_specs[FieldName.HdrSequence] = FieldSpec(field_name=FieldName.HdrSequence,
                                                             offset=3, length=4,
                                                             field_type=FieldType.Binary)

        self._field_specs[FieldName.HdrLength].value(8)
        self._field_specs[FieldName.HdrCount].value(hdr_count)
        self._field_specs[FieldName.HdrUnit].value(hdr_unit)
        self._field_specs[FieldName.HdrSequence].value(hdr_sequence)

    def get_bytes_old(self):
        self.calculate()

        final_msg = []

        # Hdr Length
        hdr_length = self._hdr_length.to_bytes(length=2, byteorder='little')
        final_msg.extend(hdr_length)

        # Hdr Count
        final_msg.append(self._hdr_count)

        # Hdr Unit
        final_msg.append(self._hdr_unit)

        # Hdr Sequence
        hdr_seq = self._hdr_sequence.to_bytes(length=4, byteorder='little')
        final_msg.extend(hdr_seq)
        return bytearray(final_msg)


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


class Time(MessageBase):
    """
        A Time message is immediately generated and sent when there is a PITCH
        event for a given clock second.
    """
    def __init__(self, time: int = None):
        self._field_specs: OrderedDict[FieldName, FieldSpec] = collections.OrderedDict()
        self._field_specs[FieldName.Length] = FieldSpec(field_name=FieldName.Length,
                                                        offset=0, length=1,
                                                        field_type=FieldType.Binary,
                                                        value=6)  # TODO: Calculate length
        self._field_specs[FieldName.MessageType] = FieldSpec(field_name=FieldName.MessageType,
                                                             offset=1, length=1,
                                                             field_type=FieldType.Value,
                                                             value=0x20)
        seconds_since_midnight = time
        if time is None:
            now = datetime.now()
            seconds_since_midnight = (now - now.replace(hour=0, minute=0, second=0, microsecond=0)).total_seconds()
        self._field_specs[FieldName.Time] = FieldSpec(field_name=FieldName.Time,
                                                      offset=2, length=4,
                                                      field_type=FieldType.Binary,
                                                      value=seconds_since_midnight)


class AddOrder(MessageBase):
    """
        Represents a newly accepted visible order on the Cboe book.
    """
    class AddOrderType(Enum):
        Long = 1
        Short = 2

    def __init__(self,
                 time_offset: int,
                 order_id: str,
                 side: str,
                 quantity: int,
                 symbol: str,
                 price: int,
                 displayed: bool = True,
                 add_order_type: AddOrderType = AddOrderType.Long):

        self._field_specs: OrderedDict[FieldName, FieldSpec] = collections.OrderedDict()
        self._field_specs[FieldName.Length] = FieldSpec(field_name=FieldName.Length,
                                                        offset=0, length=1,
                                                        field_type=FieldType.Binary)

        self._field_specs[FieldName.MessageType] = FieldSpec(field_name=FieldName.MessageType,
                                                             offset=1, length=1,
                                                             field_type=FieldType.Value)
        self._field_specs[FieldName.TimeOffset] = FieldSpec(field_name=FieldName.TimeOffset,
                                                            offset=2, length=4,
                                                            field_type=FieldType.Binary,
                                                            value=time_offset)
        self._field_specs[FieldName.OrderId] = FieldSpec(field_name=FieldName.OrderId,
                                                         offset=6, length=8,
                                                         field_type=FieldType.Binary,
                                                         value=order_id)
        self._field_specs[FieldName.SideIndicator] = FieldSpec(field_name=FieldName.SideIndicator,
                                                               offset=14, length=1,
                                                               field_type=FieldType.Alphanumeric,
                                                               value=side)
        self._field_specs[FieldName.Quantity] = FieldSpec(field_name=FieldName.Quantity,
                                                          offset=15, length=4,
                                                          field_type=FieldType.Binary,
                                                          value=quantity)
        self._field_specs[FieldName.Symbol] = FieldSpec(field_name=FieldName.Symbol,
                                                        offset=19, length=6,
                                                        field_type=FieldType.PrintableAscii,
                                                        value=symbol)
        self._field_specs[FieldName.Price] = FieldSpec(field_name=FieldName.Price,
                                                       offset=25, length=8,
                                                       field_type=FieldType.BinaryLongPrice,
                                                       value=price)
        self._field_specs[FieldName.AddFlags] = FieldSpec(field_name=FieldName.AddFlags,
                                                          offset=33, length=1,
                                                          field_type=FieldType.BitField,
                                                          value=1 if displayed == 1 else 0)

        if add_order_type == AddOrder.AddOrderType.Long:
            self._field_specs[FieldName.Length].value(34)
            self._field_specs[FieldName.MessageType].value(0x21)

        elif add_order_type == AddOrder.AddOrderType.Short:
            self._field_specs[FieldName.Length].value(26)
            self._field_specs[FieldName.MessageType].value(0x22)

            self._field_specs[FieldName.Quantity].offset(15)
            self._field_specs[FieldName.Quantity].length(2)
            self._field_specs[FieldName.Symbol].offset(17)
            self._field_specs[FieldName.Symbol].length(6)
            self._field_specs[FieldName.Price].offset(23)
            self._field_specs[FieldName.Price].length(2)
            self._field_specs[FieldName.AddFlags].offset(25)
            self._field_specs[FieldName.AddFlags].length(1)


class AddOrderLong(AddOrder):
    def __init__(self,
                 time_offset: int,
                 order_id: str,
                 side: str,
                 quantity: int,
                 symbol: str,
                 price: int,
                 displayed: bool = True):
        super().__init__(time_offset=time_offset,
                         order_id=order_id,
                         side=side,
                         quantity=quantity,
                         symbol=symbol,
                         price=price,
                         displayed=displayed,
                         add_order_type=AddOrder.AddOrderType.Long)


class AddOrderShort(AddOrder):
    def __init__(self,
                 time_offset: int,
                 order_id: str,
                 side: str,
                 quantity: int,
                 symbol: str,
                 price: int,
                 displayed: bool = True):
        super().__init__(time_offset=time_offset,
                         order_id=order_id,
                         side=side,
                         quantity=quantity,
                         symbol=symbol,
                         price=price,
                         displayed=displayed,
                         add_order_type=AddOrder.AddOrderType.Short)


class OrderExecuted(MessageBase):
    def __init__(self,
                 time_offset: int,
                 order_id: str,
                 executed_quantity: int,
                 execution_id: str):

        self._field_specs: OrderedDict[FieldName, FieldSpec] = collections.OrderedDict()
        self._field_specs[FieldName.Length] = FieldSpec(field_name=FieldName.Length,
                                                        offset=0, length=1,
                                                        field_type=FieldType.Binary,
                                                        value=26)  # TODO: Calculate length
        self._field_specs[FieldName.MessageType] = FieldSpec(field_name=FieldName.MessageType,
                                                             offset=1, length=1,
                                                             field_type=FieldType.Value,
                                                             value=0x23)
        self._field_specs[FieldName.TimeOffset] = FieldSpec(field_name=FieldName.TimeOffset,
                                                            offset=2, length=4,
                                                            field_type=FieldType.Binary,
                                                            value=time_offset)
        self._field_specs[FieldName.OrderId] = FieldSpec(field_name=FieldName.OrderId,
                                                         offset=6, length=8,
                                                         field_type=FieldType.Binary,
                                                         value=order_id)
        self._field_specs[FieldName.ExecutedQuantity] = FieldSpec(field_name=FieldName.ExecutedQuantity,
                                                                  offset=14, length=4,
                                                                  field_type=FieldType.Binary,
                                                                  value=executed_quantity)
        self._field_specs[FieldName.ExecutionId] = FieldSpec(field_name=FieldName.ExecutionId,
                                                             offset=18, length=8,
                                                             field_type=FieldType.Binary,
                                                             value=execution_id)

