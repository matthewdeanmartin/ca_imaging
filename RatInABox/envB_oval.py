import numpy as np
from ratinabox.Environment import Environment
from ratinabox.Agent import Agent
from CombinedPlaceTebcNeurons import CombinedPlaceTebcNeurons

#modeling environment B (oval)
#using equation from https://www.biorxiv.org/content/10.1101/2023.10.08.561112v1.full :
'''
Place and grid cell rate maps were generated from a real exploration trajectory using
the open source Python software RatInABox. The respective activity rates are then used
to train a logistic regressor to predict the real activity of each individual neurons.
To evaluate each model performance, we computed a F1 score for each neuron using
a place input model, which penalizes both incorrect classifications of active and inactive periods.
'''

#allows me to upload my own trajectory <-- I HAVE TO SCALE THIS
# Similar to EnvA, but with adjustments for EnvB dimensions and trajectory data


def simulate_envB(position_data):
    # Convert inches to meters for environment dimensions
    width_in_meters = 18 * 0.0254
    height_in_meters = 26 * 0.0254

    # Create an oval-shaped environment
    # Custom implementation for oval shape needed here
    env = Environment(size=(width_in_meters, height_in_meters), boundary_conditions='solid')

    # Create an agent in the environment
    agent = Agent(environment=env)

    # Number of neurons
    N = 900  # Adjust as needed

    # Create CombinedPlaceTebcNeurons
    combined_neurons = CombinedPlaceTebcNeurons(environment=env, N=N)

    # Initialize an array to store firing rates
    firing_rates = np.zeros((N, position_data.shape[1]))

    # Iterate over the trajectory data
    for index in range(position_data.shape[1]):  # Iterate over columns
        # Update agent's position
        agent.position = np.array([position_data[1, index], position_data[2, index]])  # x and y

        # Update neuron's state
        combined_neurons.update_state(agent.position, position_data[0, index])  # timestamp

        # Store firing rates
        firing_rates[:, index] = combined_neurons.get_firing_rates()

    # Return the firing rates for further analysis
    return firing_rates
