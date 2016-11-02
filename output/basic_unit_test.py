import os
import random
import logging

try:
    import matplotlib.pyplot as plt
except ImportError:
    plt = None

# Import the ChipTools base test class, our test classes should be derived from
# the ChipToolsTest class (which is derived from unittest.TestCase)
from chiptools.testing.testloader import ChipToolsTest

# The logging system is already configured by ChipTools, any messages you print
# here will be formatted and displayed using the ChipTools logger config.
log = logging.getLogger(__name__)
base = os.path.dirname(__file__)

class AxiExampleTestBase(ChipToolsTest):
    # Specify the duration your test should run for in seconds.
    # If the test should run until the testbench aborts itself use 0.
    duration = 0
    # Testbench generics are defined in this dictionary.
    # In this example we set the 'width' generic to 32, it can be overridden
    # by your tests to check different configurations.
    generics = {'axi_data_width': 32, 'axi_addr_width': 16}
    # Specify the entity that this Test should target
    entity = 'tb_axi_lite_slave_example'
    # Specify the library that this Test should target
    library = 'lib_tb_example'
    # Add a reference to the Max Hold project so that we can run this TestCase
    # directly as well as through the ChipTools testing framework.
    project = os.path.join(base, 'axi_lite_slave_example_project.xml')

    def setUp(self):
        """Place any code that is required to prepare simulator inputs in this
        method."""
        # Set the paths for the input and output files using the
        # 'simulation_root' attribute as the working directory
        self.input_path = os.path.join(self.simulation_root, 'input.txt')
        self.output_path = os.path.join(self.simulation_root, 'output.txt')

    def tearDown(self):
        """Insert any cleanup code to remove generated files in this method."""
        os.remove(self.input_path)
        os.remove(self.output_path)
        pass

    def run_random_data(self, n):
        # Generate a list of n random integers
        self.values = [random.randint(0, 2**32-1) for i in range(n)]

        # Write the values to the testbench input file
        with open(self.input_path, 'w') as f:
            for value in self.values:
                f.write(
                    'write 1004 %08x\n' % (value),  # write addr_hex data_hex
                )
                f.write(
                    'read  1004 0\n',  # read addr_hex [dummy_hex]
                )

        # Run the simulation
        return_code, stdout, stderr = self.simulate()
        self.assertEqual(return_code, 0)

        # Read the simulation output
        output_values = []
        with open(self.output_path, 'r') as f:
            data = f.readlines()
        for valueIdx, value in enumerate(data):
            # testbench response
            output_values.append(int(value, 16))  # hex to integer

        # Compare the expected result to what the Testbench returned:
        self.assertListEqual(self.values, output_values)

    def test_10_random_integers(self):
        """Check the component using 10 random integers."""
        self.run_random_data(10)

    def test_100_random_integers(self):
        """Check the component using 100 random integers."""
        self.run_random_data(100)

    def test_example_program(self):
        """Check for component using example program."""

        log.info('== test_user_program starts.')
        log.info('== Generate a list of n random integers')
        # Generate a list of n random integers
        self.values = [random.randint(0, 2**32-1) for i in range(10)]

        with open(self.input_path, 'w') as f:
            for value in self.values:
                f.write(
                    'write 1004 %08x\n' % (value),  # write addr_hex data_hex
                )
                f.write(
                    'read  1004 0\n',  # read addr_hex [dummy_hex]
                )
                # f.write(
                #     'wait %x 1\n' % (1000000),  # wait repeat_count_hex step_time_hex(ns)
                # )
            f.write(
                'wait %x 1\n' % (1000000),  # wait repeat_count_hex step_time_hex(ns)
            )
            f.write(
                'wait_clock %x\n' % (100),  # wait_clock_hex [dummy_hex]
            )

        # Run the simulation
        return_code, stdout, stderr = self.simulate()
        self.assertEqual(return_code, 0)

        # Read the simulation output
        output_values = []
        with open(self.output_path, 'r') as f:
            for value in f:
                # testbench response
                output_values.append(int(value, 16))  # Binary to integer

        # Compare the expected result to what the Testbench returned:
        self.assertListEqual(self.values, output_values)

        log.info('== test_user_program ends.')

