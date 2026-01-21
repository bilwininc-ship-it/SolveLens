import { motion } from 'motion/react';
import { Clock, ChevronRight } from 'lucide-react';

interface Activity {
  id: string;
  query: string;
  category: string;
  time: string;
  tag: string;
}

const recentActivities: Activity[] = [
  {
    id: '1',
    query: 'Schrödinger equation derivation for hydrogen atom',
    category: 'Physics',
    time: '2 hours ago',
    tag: '#Physics'
  },
  {
    id: '2',
    query: 'Modal logic and possible worlds semantics',
    category: 'Logic',
    time: '5 hours ago',
    tag: '#Logic'
  },
  {
    id: '3',
    query: 'Fourier transform applications in signal processing',
    category: 'Mathematics',
    time: '1 day ago',
    tag: '#Mathematics'
  },
  {
    id: '4',
    query: 'Thermodynamic entropy vs information entropy comparison',
    category: 'Physics',
    time: '1 day ago',
    tag: '#Physics'
  },
  {
    id: '5',
    query: 'Gödel\'s incompleteness theorems proof structure',
    category: 'Logic',
    time: '2 days ago',
    tag: '#Logic'
  }
];

export function RecentActivity() {
  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <h2 
          className="text-2xl"
          style={{ 
            color: '#0A192F',
            fontFamily: 'var(--font-family-heading)'
          }}
        >
          Recent Scholarly Activity
        </h2>
        
        <button 
          className="text-sm opacity-60 hover:opacity-100 transition-opacity flex items-center gap-1"
          style={{ 
            color: '#0A192F',
            fontFamily: 'var(--font-family-body)'
          }}
        >
          View all
          <ChevronRight className="w-4 h-4" />
        </button>
      </div>
      
      <div className="space-y-2">
        {recentActivities.map((activity, index) => (
          <motion.div
            key={activity.id}
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ 
              duration: 0.4, 
              delay: index * 0.08,
              ease: "easeOut" 
            }}
            whileHover={{ x: 4 }}
            className="group flex items-center justify-between p-4 bg-white rounded-lg cursor-pointer"
            style={{
              border: '1px solid rgba(10, 25, 47, 0.06)',
              transition: 'all 0.2s ease'
            }}
          >
            <div className="flex items-center gap-4 flex-1 min-w-0">
              <div 
                className="flex items-center justify-center w-10 h-10 rounded-full flex-shrink-0"
                style={{
                  backgroundColor: 'rgba(10, 25, 47, 0.05)'
                }}
              >
                <Clock 
                  className="w-4 h-4"
                  style={{ 
                    color: '#0A192F',
                    strokeWidth: 1.5
                  }}
                />
              </div>
              
              <div className="flex-1 min-w-0">
                <p 
                  className="mb-1 truncate"
                  style={{ 
                    color: '#0A192F',
                    fontFamily: 'var(--font-family-body)',
                    fontSize: '0.9375rem'
                  }}
                >
                  {activity.query}
                </p>
                
                <div className="flex items-center gap-3">
                  <span 
                    className="inline-block px-2.5 py-0.5 rounded-full text-xs"
                    style={{
                      backgroundColor: 'rgba(0, 240, 255, 0.1)',
                      color: '#0A192F',
                      fontFamily: 'var(--font-family-body)',
                      border: '1px solid rgba(0, 240, 255, 0.2)'
                    }}
                  >
                    {activity.tag}
                  </span>
                  
                  <span 
                    className="text-xs opacity-50"
                    style={{ 
                      color: '#0A192F',
                      fontFamily: 'var(--font-family-body)'
                    }}
                  >
                    {activity.time}
                  </span>
                </div>
              </div>
            </div>
            
            <ChevronRight 
              className="w-5 h-5 opacity-0 group-hover:opacity-40 transition-opacity flex-shrink-0 ml-2"
              style={{ color: '#0A192F' }}
            />
          </motion.div>
        ))}
      </div>
    </div>
  );
}
