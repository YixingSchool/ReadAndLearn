import tensorflow as tf
from tensorflow.examples.tutorials.mnist import input_data
mnist = input_data.read_data_sets("./data", one_hot=True)

learning_rate = 1e-3
training_steps = 2500
batch_size = 100
display_step = 100

def evaluate(logits):
    # Define loss and optimizer
    loss_op = tf.reduce_mean(
        tf.nn.softmax_cross_entropy_with_logits(logits=logits,
                                                labels=Y))
    train_op = tf.train.AdamOptimizer(
        learning_rate=learning_rate).minimize(loss_op)
    
    # Define prediction and accuracy
    prediction = tf.nn.softmax(logits)
    correct_pred = tf.equal(tf.argmax(prediction, 1), tf.argmax(Y, 1))
    accuracy = tf.reduce_mean(tf.cast(correct_pred, tf.float32))

    # start session to evaluate
    with tf.Session() as sess:
        sess.run(tf.global_variables_initializer())
        for step in range(1, training_steps + 1):
            batch_x, batch_y = mnist.train.next_batch(
                batch_size)
            sess.run(train_op, feed_dict={X: batch_x,
                                          Y: batch_y})
            if step % display_step == 0 or step == 1:
                loss, acc = sess.run([loss_op, accuracy], feed_dict={X: batch_x,
                                                                     Y: batch_y})
                print("Step " + str(step) + ", Minibatch Loss= " + \
                      "{:.4f}".format(loss) + ", Training Accuracy= " + \
                      "{:.3f}".format(acc))
        print("Optimization Finished!")
        # Evaluate result in test set
        test_data = mnist.test.images
        test_label = mnist.test.labels
        print("Testing Accuracy:", sess.run(accuracy, feed_dict={X: test_data, Y: test_label}))

num_input = 28     # img shape: 28*28
seq_steps = 28     # think about pass one column each seq
num_neurons = 128  # hidden layer num of features
num_classes = 10   # MNIST total classes (0-9 digits)
tf.reset_default_graph()
# input
X = tf.placeholder("float", [None, seq_steps * num_input])
# labels
Y = tf.placeholder("float", [None, num_classes])

# Define weights and biases for input and output layers
weights = {
    'in': tf.Variable(tf.random_normal([num_input, num_neurons])),
    'out': tf.Variable(tf.random_normal([num_neurons, num_classes]))
}
biases = {
    'in': tf.Variable(tf.random_normal([num_neurons])),
    'out': tf.Variable(tf.random_normal([num_classes]))
}

def RNN(rnn_cell):
    # convert from 1x764 to 28x28
    image_2d = tf.reshape(X, [-1, num_input])
    input_layer = tf.reshape(image_2d,  [-1, seq_steps, num_input])
    outputs, final_state = tf.nn.dynamic_rnn(cell=rnn_cell,
                                             inputs=input_layer,
                                             dtype=tf.float32)

    # We only care output of last sequence which is 2nd dimension in outputs!
    # the following two lines are the same.
    #return tf.matmul(outputs[:, -1, :], weights['out']) + biases['out'], outputs, final_state
    return tf.matmul(final_state, weights['out']) + biases['out'], outputs, final_state


basic_rnn_tanh = tf.contrib.rnn.BasicRNNCell(num_neurons, activation=tf.nn.tanh)
logit, outputs, state = RNN(basic_rnn_tanh)
test_data = mnist.test.images
test_label = mnist.test.labels
with tf.Session() as sess:
    
    sess.run(tf.global_variables_initializer())
    s, o=sess.run([state, outputs], feed_dict={X: test_data, Y: test_label})
    #print(s.shape, o.shape)
    #print(s[0], o[0][-1]) # they are same
evaluate(logit)

evaluate(RNN(tf.contrib.rnn.BasicLSTMCell(num_neurons)))