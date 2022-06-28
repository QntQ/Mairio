import gym
import gym_mairio
import numpy as np
from helper_functions_python import *
from gather_data import gather_data
from config import frame_count
from train_matrix_from_data import *
from encoding import *
import random
inputs = {"A": False,
          "B": False,
          "Y": False,
          "X": False,
          "Left": False,
          "Right": False,
          "Up": False,
          "Down": False}


env = gym.make("mairio-v0")  # Create the environment


def start_training_simulation():
    state = env.reset()
    run_number = 0
    frame = 0
    reset_flag = False
    action_unedited_list = []
    state_list = []
    reward_list = []
    while frame < frame_count or not reset_flag:

        action_unedited = int_to_action(env.action_space.sample())
        
        action = convert_action(action_unedited)
        state, reward, reset_flag = env.step(action)
        action_unedited_list.append(action_unedited)
        state_list.append(state)
        reward_list.append(reward)
        frame += 1
        # env.render()
        if reset_flag:
            gather_data(action_unedited_list, state_list,
                        reward_list, run_number, frame)
            action_unedited_list = []
            state_list = []
            reward_list = []
            reset_reset()
            run_number += 1
            env.reset()


def start_q_table_simulation():
    q_table = load_q_table()
    encoding = load_encoding()

    action_unedited_list = []
    state_list = []
    reward_list = []

    state = env.reset()
    state = tuple(state.flatten())
    
    reset_flag = False
    run_number = 0
    epsilon = 0.05
    frame = 0
    unknown_states = 0
    while frame < frame_count or not reset_flag:
        print(frame)
        if random.uniform(0, 1) < epsilon:
            action_unedited = int_to_action(env.action_space.sample())
        else:
            if state in encoding:
                index_action = np.argmax(q_table[:, encoding[state]])
                action_unedited = int_to_action(index_action)
            else:
                unknown_states += 1
                action_unedited = int_to_action(env.action_space.sample())

        action = convert_action(action_unedited)
        state, reward, reset_flag = env.step(action)

        print(reward)
        state = tuple(state.flatten())
        frame += 1
        action_unedited_list.append(action_unedited)
        state_list.append(state)
        reward_list.append(reward)
        if reset_flag:
            for i in range(8):
                reward_list[len(reward_list)-1] -= 3500
            q_table = update_q_table(
                state_list, action_unedited_list, reward_list, q_table, encoding)
            action_unedited_list = []
            state_list = []
            reward_list = []
            reset_reset()
            run_number += 1
            env.reset()
    print("unknown:", unknown_states)

    save_encoding(encoding)
    with open("q_table.npy", "wb") as f:
        np.save(f, q_table)


if __name__ == "__main__":
    # start_training_simulation()
    # train_q_table()
    start_q_table_simulation()
    #encoding = load_encoding()
    print(encoding)
    