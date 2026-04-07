class GraphEdge {
  final int senderId;
  final int receiverId;
  final int weight;

  GraphEdge({
    required this.senderId,
    required this.receiverId,
    required this.weight,
  });

  Map<String, dynamic> toJson() {
    return {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'weight': weight,
    };
  }

  factory GraphEdge.fromJson(Map<String, dynamic> json) {
    return GraphEdge(
      senderId: json['sender_id'] ?? json['senderId'] ?? 0,
      receiverId: json['receiver_id'] ?? json['receiverId'] ?? 0,
      weight: json['weight'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'GraphEdge(senderId: $senderId, receiverId: $receiverId, weight: $weight)';
  }
}

class PublicInputs {
  final String graphRoot;
  final int threshold;

  PublicInputs({
    required this.graphRoot,
    required this.threshold,
  });

  Map<String, dynamic> toJson() {
    return {
      'graph_root': graphRoot,
      'threshold': threshold,
    };
  }

  factory PublicInputs.fromJson(Map<String, dynamic> json) {
    return PublicInputs(
      graphRoot: json['graph_root'] ?? json['graphRoot'] ?? '',
      threshold: json['threshold'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'PublicInputs(graphRoot: $graphRoot, threshold: $threshold)';
  }
}

class ClientWitness {
  final GraphEdge edge;
  final String commitment;

  ClientWitness({
    required this.edge,
    required this.commitment,
  });

  Map<String, dynamic> toJson() {
    return {
      'edge': edge.toJson(),
      'commitment': commitment,
    };
  }

  factory ClientWitness.fromJson(Map<String, dynamic> json) {
    return ClientWitness(
      edge: GraphEdge.fromJson(json['edge'] ?? {}),
      commitment: json['commitment'] ?? '',
    );
  }

  @override
  String toString() {
    return 'ClientWitness(edge: $edge, commitment: $commitment)';
  }
}

class ZKProof {
  final List<int> proofBytes;
  final String rootCommitment;

  ZKProof({
    required this.proofBytes,
    required this.rootCommitment,
  });

  Map<String, dynamic> toJson() {
    return {
      'proof_bytes': proofBytes,
      'root_commitment': rootCommitment,
    };
  }

  factory ZKProof.fromJson(Map<String, dynamic> json) {
    return ZKProof(
      proofBytes: List<int>.from(json['proof_bytes'] ?? []),
      rootCommitment: json['root_commitment'] ?? json['rootCommitment'] ?? '',
    );
  }

  @override
  String toString() {
    return 'ZKProof(proofBytes: ${proofBytes.length} bytes, rootCommitment: $rootCommitment)';
  }
}
