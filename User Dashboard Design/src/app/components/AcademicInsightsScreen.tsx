import { useState } from 'react';
import { motion } from 'motion/react';
import { ArrowLeft, TrendingUp, Clock, FileText, Sparkles } from 'lucide-react';
import { BarChart, Bar, LineChart, Line, PieChart, Pie, Cell, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend } from 'recharts';

interface AcademicInsightsScreenProps {
  onBack: () => void;
}

// Mock data for charts
const inquiryDistributionData = [
  { category: 'Physics', count: 12, percentage: 35 },
  { category: 'Mathematics', count: 8, percentage: 23 },
  { category: 'Computer Science', count: 7, percentage: 20 },
  { category: 'History', count: 5, percentage: 15 },
  { category: 'Other', count: 2, percentage: 7 }
];

const progressOverTimeData = [
  { week: 'Week 1', complexity: 3.2, activity: 5 },
  { week: 'Week 2', complexity: 3.8, activity: 7 },
  { week: 'Week 3', complexity: 4.1, activity: 8 },
  { week: 'Week 4', complexity: 4.5, activity: 12 },
  { week: 'Week 5', complexity: 4.8, activity: 10 },
  { week: 'Week 6', complexity: 5.2, activity: 15 }
];

const resourceUtilizationData = [
  { type: 'PDFs', count: 18 },
  { type: 'Images', count: 12 },
  { type: 'Notes', count: 24 }
];

const COLORS = ['#00F0FF', '#0A192F', '#1A2F4F', '#2A4F6F', '#3A6F8F'];

export function AcademicInsightsScreen({ onBack }: AcademicInsightsScreenProps) {
  const [isGenerating, setIsGenerating] = useState(false);

  const handleGenerateReport = () => {
    setIsGenerating(true);
    setTimeout(() => {
      setIsGenerating(false);
    }, 2000);
  };

  return (
    <div 
      className="fixed inset-0 flex flex-col"
      style={{ background: '#F9F9F7' }}
    >
      {/* Header */}
      <div 
        className="flex items-center justify-between px-6 py-4"
        style={{ 
          background: '#F9F9F7',
          borderBottom: '1px solid rgba(10, 25, 47, 0.1)'
        }}
      >
        <button
          onClick={onBack}
          className="flex items-center gap-2 opacity-60 hover:opacity-100 transition-opacity"
          style={{ 
            color: '#0A192F',
            fontFamily: 'var(--font-family-body)'
          }}
        >
          <ArrowLeft className="w-5 h-5" />
          <span>Back</span>
        </button>

        <h1
          className="text-2xl"
          style={{
            color: '#0A192F',
            fontFamily: 'var(--font-family-heading)'
          }}
        >
          Academic Insights
        </h1>

        <div className="w-20"></div>
      </div>

      {/* Main Content */}
      <div className="flex-1 overflow-y-auto px-6 py-6 scrollbar-thin">
        <div className="max-w-5xl mx-auto space-y-8">
          {/* Key Metrics Section */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.4 }}
          >
            <h2
              className="mb-4"
              style={{
                color: '#0A192F',
                fontFamily: 'var(--font-family-heading)',
                fontSize: '1.25rem'
              }}
            >
              Key Metrics
            </h2>
            
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              {/* Metric 1 */}
              <div
                className="p-6 rounded-xl"
                style={{
                  background: '#ffffff',
                  border: '1px solid rgba(10, 25, 47, 0.08)',
                  boxShadow: '0 2px 12px rgba(10, 25, 47, 0.04)'
                }}
              >
                <div className="flex items-start justify-between mb-3">
                  <div
                    className="flex items-center justify-center w-10 h-10 rounded-lg"
                    style={{
                      background: 'rgba(0, 240, 255, 0.1)'
                    }}
                  >
                    <TrendingUp className="w-5 h-5" style={{ color: '#00F0FF' }} />
                  </div>
                  <div
                    className="text-xs px-2 py-1 rounded"
                    style={{
                      background: 'rgba(0, 240, 255, 0.1)',
                      color: '#00F0FF',
                      fontFamily: 'var(--font-family-body)',
                      fontWeight: 600
                    }}
                  >
                    +12%
                  </div>
                </div>
                <p
                  className="mb-1"
                  style={{
                    color: '#0A192F',
                    fontFamily: 'var(--font-family-body)',
                    fontSize: '0.875rem',
                    opacity: 0.6
                  }}
                >
                  Avg. Inquiry Complexity
                </p>
                <p
                  style={{
                    color: '#0A192F',
                    fontFamily: 'var(--font-family-heading)',
                    fontSize: '2rem',
                    fontWeight: 600
                  }}
                >
                  Advanced
                </p>
              </div>

              {/* Metric 2 */}
              <div
                className="p-6 rounded-xl"
                style={{
                  background: '#ffffff',
                  border: '1px solid rgba(10, 25, 47, 0.08)',
                  boxShadow: '0 2px 12px rgba(10, 25, 47, 0.04)'
                }}
              >
                <div className="flex items-start justify-between mb-3">
                  <div
                    className="flex items-center justify-center w-10 h-10 rounded-lg"
                    style={{
                      background: 'rgba(0, 240, 255, 0.1)'
                    }}
                  >
                    <Clock className="w-5 h-5" style={{ color: '#00F0FF' }} />
                  </div>
                  <div
                    className="text-xs px-2 py-1 rounded"
                    style={{
                      background: 'rgba(0, 240, 255, 0.1)',
                      color: '#00F0FF',
                      fontFamily: 'var(--font-family-body)',
                      fontWeight: 600
                    }}
                  >
                    +8%
                  </div>
                </div>
                <p
                  className="mb-1"
                  style={{
                    color: '#0A192F',
                    fontFamily: 'var(--font-family-body)',
                    fontSize: '0.875rem',
                    opacity: 0.6
                  }}
                >
                  Focus Time Last Week
                </p>
                <p
                  style={{
                    color: '#0A192F',
                    fontFamily: 'var(--font-family-heading)',
                    fontSize: '2rem',
                    fontWeight: 600
                  }}
                >
                  4h 30m
                </p>
              </div>

              {/* Metric 3 */}
              <div
                className="p-6 rounded-xl"
                style={{
                  background: '#ffffff',
                  border: '1px solid rgba(10, 25, 47, 0.08)',
                  boxShadow: '0 2px 12px rgba(10, 25, 47, 0.04)'
                }}
              >
                <div className="flex items-start justify-between mb-3">
                  <div
                    className="flex items-center justify-center w-10 h-10 rounded-lg"
                    style={{
                      background: 'rgba(0, 240, 255, 0.1)'
                    }}
                  >
                    <FileText className="w-5 h-5" style={{ color: '#00F0FF' }} />
                  </div>
                  <div
                    className="text-xs px-2 py-1 rounded"
                    style={{
                      background: 'rgba(0, 240, 255, 0.1)',
                      color: '#00F0FF',
                      fontFamily: 'var(--font-family-body)',
                      fontWeight: 600
                    }}
                  >
                    +15
                  </div>
                </div>
                <p
                  className="mb-1"
                  style={{
                    color: '#0A192F',
                    fontFamily: 'var(--font-family-body)',
                    fontSize: '0.875rem',
                    opacity: 0.6
                  }}
                >
                  Documents Analyzed
                </p>
                <p
                  style={{
                    color: '#0A192F',
                    fontFamily: 'var(--font-family-heading)',
                    fontSize: '2rem',
                    fontWeight: 600
                  }}
                >
                  54
                </p>
              </div>
            </div>
          </motion.div>

          {/* Inquiry Distribution Chart */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.4, delay: 0.1 }}
            className="p-6 rounded-xl"
            style={{
              background: '#ffffff',
              border: '1px solid rgba(10, 25, 47, 0.08)',
              boxShadow: '0 2px 12px rgba(10, 25, 47, 0.04)'
            }}
          >
            <h3
              className="mb-6"
              style={{
                color: '#0A192F',
                fontFamily: 'var(--font-family-heading)',
                fontSize: '1.125rem'
              }}
            >
              Inquiry Distribution by Category
            </h3>
            
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={inquiryDistributionData}>
                <CartesianGrid strokeDasharray="3 3" stroke="rgba(10, 25, 47, 0.05)" />
                <XAxis 
                  dataKey="category" 
                  stroke="#0A192F"
                  style={{ 
                    fontFamily: 'var(--font-family-body)',
                    fontSize: '0.875rem',
                    opacity: 0.6
                  }}
                />
                <YAxis 
                  stroke="#0A192F"
                  style={{ 
                    fontFamily: 'var(--font-family-body)',
                    fontSize: '0.875rem',
                    opacity: 0.6
                  }}
                />
                <Tooltip 
                  contentStyle={{
                    background: '#ffffff',
                    border: '1px solid rgba(10, 25, 47, 0.1)',
                    borderRadius: '8px',
                    fontFamily: 'var(--font-family-body)',
                    fontSize: '0.875rem'
                  }}
                />
                <Bar dataKey="count" fill="#00F0FF" radius={[8, 8, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </motion.div>

          {/* Progress Over Time Chart */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.4, delay: 0.2 }}
            className="p-6 rounded-xl"
            style={{
              background: '#ffffff',
              border: '1px solid rgba(10, 25, 47, 0.08)',
              boxShadow: '0 2px 12px rgba(10, 25, 47, 0.04)'
            }}
          >
            <h3
              className="mb-6"
              style={{
                color: '#0A192F',
                fontFamily: 'var(--font-family-heading)',
                fontSize: '1.125rem'
              }}
            >
              Progress Over Time
            </h3>
            
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={progressOverTimeData}>
                <CartesianGrid strokeDasharray="3 3" stroke="rgba(10, 25, 47, 0.05)" />
                <XAxis 
                  dataKey="week" 
                  stroke="#0A192F"
                  style={{ 
                    fontFamily: 'var(--font-family-body)',
                    fontSize: '0.875rem',
                    opacity: 0.6
                  }}
                />
                <YAxis 
                  stroke="#0A192F"
                  style={{ 
                    fontFamily: 'var(--font-family-body)',
                    fontSize: '0.875rem',
                    opacity: 0.6
                  }}
                />
                <Tooltip 
                  contentStyle={{
                    background: '#ffffff',
                    border: '1px solid rgba(10, 25, 47, 0.1)',
                    borderRadius: '8px',
                    fontFamily: 'var(--font-family-body)',
                    fontSize: '0.875rem'
                  }}
                />
                <Legend 
                  wrapperStyle={{
                    fontFamily: 'var(--font-family-body)',
                    fontSize: '0.875rem'
                  }}
                />
                <Line 
                  type="monotone" 
                  dataKey="complexity" 
                  stroke="#00F0FF" 
                  strokeWidth={3}
                  dot={{ fill: '#00F0FF', r: 5 }}
                  name="Complexity Score"
                />
                <Line 
                  type="monotone" 
                  dataKey="activity" 
                  stroke="#0A192F" 
                  strokeWidth={3}
                  dot={{ fill: '#0A192F', r: 5 }}
                  name="Research Activity"
                />
              </LineChart>
            </ResponsiveContainer>
          </motion.div>

          {/* Resource Utilization Chart */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.4, delay: 0.3 }}
            className="p-6 rounded-xl"
            style={{
              background: '#ffffff',
              border: '1px solid rgba(10, 25, 47, 0.08)',
              boxShadow: '0 2px 12px rgba(10, 25, 47, 0.04)'
            }}
          >
            <h3
              className="mb-6"
              style={{
                color: '#0A192F',
                fontFamily: 'var(--font-family-heading)',
                fontSize: '1.125rem'
              }}
            >
              Resource Utilization
            </h3>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-8 items-center">
              <ResponsiveContainer width="100%" height={250}>
                <PieChart>
                  <Pie
                    data={resourceUtilizationData}
                    cx="50%"
                    cy="50%"
                    innerRadius={60}
                    outerRadius={90}
                    fill="#8884d8"
                    paddingAngle={5}
                    dataKey="count"
                  >
                    {resourceUtilizationData.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip 
                    contentStyle={{
                      background: '#ffffff',
                      border: '1px solid rgba(10, 25, 47, 0.1)',
                      borderRadius: '8px',
                      fontFamily: 'var(--font-family-body)',
                      fontSize: '0.875rem'
                    }}
                  />
                </PieChart>
              </ResponsiveContainer>

              <div className="space-y-3">
                {resourceUtilizationData.map((item, index) => (
                  <div key={item.type} className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <div
                        className="w-4 h-4 rounded"
                        style={{ background: COLORS[index % COLORS.length] }}
                      />
                      <span
                        style={{
                          color: '#0A192F',
                          fontFamily: 'var(--font-family-body)',
                          fontSize: '0.875rem'
                        }}
                      >
                        {item.type}
                      </span>
                    </div>
                    <span
                      style={{
                        color: '#0A192F',
                        fontFamily: 'var(--font-family-heading)',
                        fontSize: '1.125rem',
                        fontWeight: 600
                      }}
                    >
                      {item.count}
                    </span>
                  </div>
                ))}
              </div>
            </div>
          </motion.div>

          {/* Generate Report Button */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.4, delay: 0.4 }}
            className="flex justify-center pb-8"
          >
            <motion.button
              onClick={handleGenerateReport}
              disabled={isGenerating}
              whileTap={{ scale: 0.95 }}
              className="flex items-center gap-2 px-8 py-4 rounded-xl"
              style={{
                background: isGenerating 
                  ? 'rgba(10, 25, 47, 0.6)'
                  : 'linear-gradient(135deg, #0A192F 0%, #1A2F4F 100%)',
                color: '#00F0FF',
                fontFamily: 'var(--font-family-body)',
                fontWeight: 600,
                boxShadow: '0 4px 16px rgba(10, 25, 47, 0.2)',
                opacity: isGenerating ? 0.6 : 1
              }}
            >
              <Sparkles className="w-5 h-5" />
              {isGenerating ? 'Generating Report...' : 'Generate New Insight Report'}
            </motion.button>
          </motion.div>
        </div>
      </div>
    </div>
  );
}
