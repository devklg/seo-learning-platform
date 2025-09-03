// client/src/pages/Playground.jsx
import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { 
  Search, Globe, Link, BarChart3, Code, 
  Zap, AlertCircle, CheckCircle, XCircle 
} from 'lucide-react';
import axios from 'axios';
import toast from 'react-hot-toast';

const Playground = () => {
  const [activeTab, setActiveTab] = useState('seo-analyzer');
  const [loading, setLoading] = useState(false);
  const [results, setResults] = useState(null);

  // SEO Analyzer State
  const [url, setUrl] = useState('');
  
  // Keyword Research State
  const [keyword, setKeyword] = useState('');
  
  // SERP Simulator State
  const [serpData, setSerpData] = useState({
    title: '',
    description: '',
    url: ''
  });

  const handleSEOAnalysis = async () => {
    if (!url) {
      toast.error('Please enter a URL');
      return;
    }

    setLoading(true);
    try {
      const response = await axios.post('/api/playground/analyze-url', { url });
      setResults(response.data);
      toast.success('Analysis complete!');
    } catch (error) {
      toast.error('Analysis failed. Please try again.');
    }
    setLoading(false);
  };

  const handleKeywordResearch = async () => {
    if (!keyword) {
      toast.error('Please enter a keyword');
      return;
    }

    setLoading(true);
    try {
      const response = await axios.post('/api/playground/keyword-research', { keyword });
      setResults(response.data);
      toast.success('Research complete!');
    } catch (error) {
      toast.error('Research failed. Please try again.');
    }
    setLoading(false);
  };

  const handleSERPSimulation = async () => {
    if (!serpData.title || !serpData.description) {
      toast.error('Please enter title and description');
      return;
    }

    setLoading(true);
    try {
      const response = await axios.post('/api/playground/serp-simulator', serpData);
      setResults(response.data);
      toast.success('SERP preview generated!');
    } catch (error) {
      toast.error('Simulation failed. Please try again.');
    }
    setLoading(false);
  };

  const tabs = [
    { id: 'seo-analyzer', label: 'SEO Analyzer', icon: Search },
    { id: 'keyword-research', label: 'Keyword Research', icon: BarChart3 },
    { id: 'serp-simulator', label: 'SERP Simulator', icon: Globe },
    { id: 'backlink-checker', label: 'Backlink Checker', icon: Link }
  ];

  return (
    <div className="p-6 max-w-7xl mx-auto">
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="mb-8"
      >
        <h1 className="text-4xl font-bold mb-2 gradient-text">SEO Playground</h1>
        <p className="text-slate-400">Practice SEO techniques with real-time tools</p>
      </motion.div>

      {/* Tabs */}
      <div className="flex flex-wrap gap-2 mb-8">
        {tabs.map(tab => (
          <button
            key={tab.id}
            onClick={() => setActiveTab(tab.id)}
            className={`flex items-center gap-2 px-4 py-2 rounded-lg transition-all ${
              activeTab === tab.id
                ? 'bg-gradient-to-r from-blue-500 to-purple-600 text-white'
                : 'bg-slate-800 text-slate-400 hover:text-white'
            }`}
          >
            <tab.icon className="w-4 h-4" />
            <span>{tab.label}</span>
          </button>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Input Section */}
        <motion.div
          initial={{ opacity: 0, x: -20 }}
          animate={{ opacity: 1, x: 0 }}
          className="glass rounded-2xl p-6 border border-slate-800"
        >
          <h2 className="text-xl font-bold mb-4">Input</h2>

          {activeTab === 'seo-analyzer' && (
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-slate-300 mb-2">
                  Website URL
                </label>
                <input
                  type="url"
                  value={url}
                  onChange={(e) => setUrl(e.target.value)}
                  placeholder="https://example.com"
                  className="w-full px-4 py-3 bg-slate-800/50 border border-slate-700 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
              <button
                onClick={handleSEOAnalysis}
                disabled={loading}
                className="w-full py-3 bg-gradient-to-r from-blue-500 to-purple-600 text-white font-semibold rounded-xl hover:shadow-lg hover:shadow-blue-500/25 transition-all disabled:opacity-50"
              >
                {loading ? 'Analyzing...' : 'Analyze SEO'}
              </button>
            </div>
          )}

          {activeTab === 'keyword-research' && (
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-slate-300 mb-2">
                  Target Keyword
                </label>
                <input
                  type="text"
                  value={keyword}
                  onChange={(e) => setKeyword(e.target.value)}
                  placeholder="e.g., SEO tips"
                  className="w-full px-4 py-3 bg-slate-800/50 border border-slate-700 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
              <button
                onClick={handleKeywordResearch}
                disabled={loading}
                className="w-full py-3 bg-gradient-to-r from-blue-500 to-purple-600 text-white font-semibold rounded-xl hover:shadow-lg hover:shadow-blue-500/25 transition-all disabled:opacity-50"
              >
                {loading ? 'Researching...' : 'Research Keyword'}
              </button>
            </div>
          )}

          {activeTab === 'serp-simulator' && (
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-slate-300 mb-2">
                  Page Title
                </label>
                <input
                  type="text"
                  value={serpData.title}
                  onChange={(e) => setSerpData({...serpData, title: e.target.value})}
                  placeholder="Your SEO-Optimized Title"
                  maxLength="60"
                  className="w-full px-4 py-3 bg-slate-800/50 border border-slate-700 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
                <p className="text-xs text-slate-500 mt-1">
                  {serpData.title.length}/60 characters
                </p>
              </div>
              <div>
                <label className="block text-sm font-medium text-slate-300 mb-2">
                  Meta Description
                </label>
                <textarea
                  value={serpData.description}
                  onChange={(e) => setSerpData({...serpData, description: e.target.value})}
                  placeholder="Your compelling meta description..."
                  maxLength="160"
                  rows="3"
                  className="w-full px-4 py-3 bg-slate-800/50 border border-slate-700 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
                <p className="text-xs text-slate-500 mt-1">
                  {serpData.description.length}/160 characters
                </p>
              </div>
              <button
                onClick={handleSERPSimulation}
                disabled={loading}
                className="w-full py-3 bg-gradient-to-r from-blue-500 to-purple-600 text-white font-semibold rounded-xl hover:shadow-lg hover:shadow-blue-500/25 transition-all disabled:opacity-50"
              >
                {loading ? 'Generating...' : 'Generate Preview'}
              </button>
            </div>
          )}
        </motion.div>

        {/* Results Section */}
        <motion.div
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          className="glass rounded-2xl p-6 border border-slate-800"
        >
          <h2 className="text-xl font-bold mb-4">Results</h2>

          {loading && (
            <div className="flex items-center justify-center py-12">
              <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500"></div>
            </div>
          )}

          {!loading && results && activeTab === 'seo-analyzer' && (
            <div className="space-y-4">
              <div className="flex items-center justify-between p-4 bg-slate-800/50 rounded-xl">
                <span className="text-slate-300">SEO Score</span>
                <span className="text-2xl font-bold text-blue-400">{results.seoScore}/100</span>
              </div>
              
              <div className="space-y-2">
                <h3 className="font-semibold text-slate-300">Recommendations:</h3>
                {results.recommendations?.map((rec, index) => (
                  <div key={index} className="flex items-start gap-2 p-3 bg-slate-800/30 rounded-lg">
                    <AlertCircle className="w-5 h-5 text-yellow-400 mt-0.5" />
                    <span className="text-sm text-slate-400">{rec}</span>
                  </div>
                ))}
              </div>
            </div>
          )}

          {!loading && results && activeTab === 'keyword-research' && (
            <div className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div className="p-4 bg-slate-800/50 rounded-xl">
                  <p className="text-xs text-slate-500 mb-1">Search Volume</p>
                  <p className="text-xl font-bold text-blue-400">{results.searchVolume}</p>
                </div>
                <div className="p-4 bg-slate-800/50 rounded-xl">
                  <p className="text-xs text-slate-500 mb-1">Difficulty</p>
                  <p className="text-xl font-bold text-purple-400">{results.difficulty}%</p>
                </div>
              </div>

              <div>
                <h3 className="font-semibold text-slate-300 mb-2">Related Keywords:</h3>
                <div className="space-y-2">
                  {results.relatedKeywords?.map((kw, index) => (
                    <div key={index} className="flex items-center justify-between p-3 bg-slate-800/30 rounded-lg">
                      <span className="text-sm text-slate-400">{kw.keyword}</span>
                      <span className="text-sm text-slate-500">{kw.volume} searches</span>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}

          {!loading && results && activeTab === 'serp-simulator' && (
            <div className="space-y-4">
              <div className="p-4 bg-slate-900 rounded-xl border border-slate-700">
                <p className="text-blue-500 text-lg font-semibold mb-1">
                  {results.title}
                </p>
                <p className="text-green-600 text-sm mb-2">{results.url}</p>
                <p className="text-slate-400 text-sm">{results.description}</p>
              </div>

              {results.warnings?.length > 0 && (
                <div className="space-y-2">
                  <h3 className="font-semibold text-slate-300">Warnings:</h3>
                  {results.warnings.map((warning, index) => (
                    <div key={index} className="flex items-start gap-2 p-3 bg-red-500/10 border border-red-500/30 rounded-lg">
                      <XCircle className="w-5 h-5 text-red-400 mt-0.5" />
                      <span className="text-sm text-red-400">{warning}</span>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}

          {!loading && !results && (
            <div className="text-center py-12 text-slate-500">
              <Code className="w-12 h-12 mx-auto mb-4 opacity-50" />
              <p>Results will appear here</p>
            </div>
          )}
        </motion.div>
      </div>
    </div>
  );
};

export default Playground;