// http://hazelcast.org/getting-started/
import com.hazelcast.config.Config;
import com.hazelcast.config.ExecutorConfig;
import com.hazelcast.core.HazelcastInstance;
import com.hazelcast.core.Hazelcast;

import java.util.Map;
import java.util.Queue;

public class Server {
   public static void main(String[] args){
      Config config = new Config();
      config.getGroupConfig()
        .setName("dev")
        .setPassword("dev-pass");
      HazelcastInstance instance = Hazelcast.newHazelcastInstance(config);
      Map<Integer, String> mapCustomers = instance.getMap("customers");
      mapCustomers.put(1, "Joe");
      mapCustomers.put(2, "Ali");
      mapCustomers.put(3, "Avi");

      System.out.println("Customer with key 1: "+ mapCustomers.get(1));
      System.out.println("Map Size:" + mapCustomers.size());

      Queue<String> queueCustomers = instance.getQueue("customers");
      queueCustomers.offer("Tom");
      queueCustomers.offer("Mary");
      queueCustomers.offer("Jane");
      System.out.println("First customer: " + queueCustomers.poll());
      System.out.println("Second customer: "+ queueCustomers.peek());
      System.out.println("Queue size: " + queueCustomers.size());
   }
}
