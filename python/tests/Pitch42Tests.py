from hamcrest import (
    assert_that,
    equal_to,
    has_length
)
import logging
from unittest import TestCase
from pitch.pitch42 import (
    AddOrderLong,
    OrderExecuted,
    SequencedUnitHeader,
    Time
)


logger = logging.getLogger(__name__)


class TestSeqUnitHeader(TestCase):
    def test_sequenced_unit_header_create(self):
        # GIVEN
        message = SequencedUnitHeader(hdr_count=0,
                                      hdr_unit=1,
                                      hdr_sequence=1)

        # WHEN
        msg_bytes = message.get_bytes()

        # THEN
        assert_that(msg_bytes, has_length(8))
        assert_that(msg_bytes, equal_to(bytearray([
            8, 0,  # Hdr Length
            0,  # Hdr Count
            1,  # Hdr Unit
            1, 0, 0, 0  # Hdr Sequence
        ])))


class TestTime(TestCase):
    def test_timestamp_create(self):
        # GIVEN
        # 34_200 seconds = 9:30 AM
        message = Time(time=34_200)

        # WHEN
        msg_bytes = message.get_bytes()

        # THEN
        assert_that(msg_bytes, has_length(6))
        assert_that(msg_bytes, equal_to(bytearray([
            6,  # Length
            0x20,  # Type
            0x98, 0x85, 0, 0  # Time
        ])))

    def test_timestamp_short_create(self):
        # GIVEN
        # 200 seconds
        message = Time(time=200)

        # WHEN
        msg_bytes = message.get_bytes()

        # THEN
        assert_that(msg_bytes, has_length(6))
        assert_that(msg_bytes, equal_to(bytearray([
            6,  # Length
            0x20,  # Type
            0xc8, 0, 0, 0  # Time
        ])))


class TestAddOrder(TestCase):
    def test_add_order_long(self):
        # GIVEN
        message = AddOrderLong(time_offset=447_000,
                               order_id='ORID0001',
                               side='B',
                               quantity=20_000,
                               symbol='AAPL',
                               price=0.9050)

        # WHEN
        msg_bytes = message.get_bytes()

        # THEN
        assert_that(msg_bytes, has_length(34))
        print('\n')
        for idx, byte_i in enumerate(msg_bytes):
            print(f' [{idx}] = {byte_i}')
        assert_that(msg_bytes, equal_to(bytearray([
            0x22,  # Length
            0x21,  # Type
            0x18, 0xD2, 6, 0,  # Time offset
            0x4f, 0x52, 0x49, 0x44, 0x30, 0x30, 0x30, 0x31,  # Order Id
            0x42,  # Side Indicator
            0x20, 0x4E, 0, 0,  # Quantity
            0x41, 0x41, 0x50, 0x4c, 0x20, 0x20,  # Symbol
            0x5A, 0x23, 0, 0, 0, 0, 0, 0,  # Price
            0x01  # AddBitField
        ])))


class TestOrderExecuted(TestCase):
    def test_order_executed(self):
        # GIVEN
        message = OrderExecuted(time_offset=447_000,
                                order_id='ORID0001',
                                executed_quantity=20_000,
                                execution_id='EXEID001')

        # WHEN
        msg_bytes = message.get_bytes()

        # THEN
        assert_that(msg_bytes, has_length(26))
        print('\n')
        for idx, byte_i in enumerate(msg_bytes):
            print(f' [{idx}] = {byte_i}')
        assert_that(msg_bytes, equal_to(bytearray([
            0x1A,  # Length
            0x23,  # Type
            0x18, 0xD2, 6, 0,  # Time offset
            0x4f, 0x52, 0x49, 0x44, 0x30, 0x30, 0x30, 0x31,  # Order Id
            0x20, 0x4E, 0, 0,  # Executed Quantity
            0x45, 0x58, 0x45, 0x49, 0x44, 0x30, 0x30, 0x31,  # Execution Id
        ])))

