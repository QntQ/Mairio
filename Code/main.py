import gym
import gym_mairio
import numpy as np
from helper_functions_python import *
inputs = {"A": False,
          "B": False,
          "Y": False,
          "X": False,
          "Left": False,
          "Right": False,
          "Up": False,
          "Down": False}


env = gym.make("mairio-v0")  # Create the environment


def start_simulation():
    state = env.reset()
    env.render()

    for _ in range(100):
        action = env.action_space.sample()
        action = convert_action(action)
        state, reward, reset_flag = env.step(action)
        if reset_flag:
            env.reset()
    # TODO: Test lua and sync
    # TODO: filter irrelevant blocks


if __name__ == "__main__":
    start_simulation()
