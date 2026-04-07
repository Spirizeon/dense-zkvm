class GraphEdge {
  final int senderId;
  final int receiverId;
  final int weight;

  const GraphEdge({
    required this.senderId,
    required this.receiverId,
    required this.weight,
  });

  Map<String, dynamic> toJson() => {
        'sender_id': senderId,
        'receiver_id': receiverId,
        'weight': weight,
      };

  factory GraphEdge.fromJson(Map<String, dynamic> json) => GraphEdge(
        senderId: json['sender_id'] ?? json['senderId'] ?? 0,
        receiverId: json['receiver_id'] ?? json['receiverId'] ?? 0,
        weight: json['weight'] ?? 0,
      );

  @override
  String toString() =>
      'GraphEdge(senderId: $senderId, receiverId: $receiverId, weight: $weight)';
}

class PublicInputs {
  final String graphRoot;
  final int threshold;

  const PublicInputs({
    required this.graphRoot,
    required this.threshold,
  });

  Map<String, dynamic> toJson() => {
        'graph_root': graphRoot,
        'threshold': threshold,
      };

  factory PublicInputs.fromJson(Map<String, dynamic> json) => PublicInputs(
        graphRoot: json['graph_root'] ?? json['graphRoot'] ?? '',
        threshold: json['threshold'] ?? 0,
      );

  @override
  String toString() => 'PublicInputs(graphRoot: $graphRoot, threshold: $threshold)';
}

class ClientWitness {
  final GraphEdge edge;
  final String commitment;

  const ClientWitness({
    required this.edge,
    required this.commitment,
  });

  factory ClientWitness.fromJson(Map<String, dynamic> json) => ClientWitness(
        edge: GraphEdge.fromJson(json['edge'] ?? {}),
        commitment: json['commitment'] ?? '',
      );

  @override
  String toString() => 'ClientWitness(edge: $edge, commitment: $commitment)';
}

class ZKProof {
  final List<int> proofBytes;
  final String rootCommitment;

  const ZKProof({
    required this.proofBytes,
    required this.rootCommitment,
  });

  factory ZKProof.fromJson(Map<String, dynamic> json) => ZKProof(
        proofBytes: List<int>.from(json['proof_bytes'] ?? []),
        rootCommitment: json['root_commitment'] ?? json['rootCommitment'] ?? '',
      );

  String get proofHex =>
      proofBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');

  @override
  String toString() =>
      'ZKProof(proofBytes: ${proofBytes.length} bytes, rootCommitment: $rootCommitment)';
}

class ServerHealth {
  final String status;
  final int uptimeSeconds;
  final int totalRequests;

  const ServerHealth({
    required this.status,
    required this.uptimeSeconds,
    required this.totalRequests,
  });

  factory ServerHealth.fromJson(Map<String, dynamic> json) => ServerHealth(
        status: json['status'] ?? '',
        uptimeSeconds: json['uptime_seconds'] ?? 0,
        totalRequests: json['total_requests'] ?? 0,
      );
}
